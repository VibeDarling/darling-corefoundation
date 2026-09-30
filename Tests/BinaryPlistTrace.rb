require 'tmpdir'
require 'open3'
root = File.expand_path('..', __dir__)
source = File.read(File.join(root, 'CFBinaryPList.c'))
helper = source[/static void __CFBinaryPlistTraceRejection\(.*?^\}/m] or abort 'helper missing'
macro = source.lines.find { |line| line.start_with?('#define FAIL_FALSE do { __CFBinaryPlistTraceRejection') } or abort 'macro missing'
Dir.mktmpdir('cf-plist-trace-') do |dir|
  File.write("#{dir}/test.c", <<~C)
    #include <assert.h>
    #include <stdbool.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <errno.h>
    #include <unistd.h>
    #{helper}
    #{macro}
    static bool reject(void) {
    #line 1234 "CFBinaryPList.c"
        FAIL_FALSE;
    }
    int main(void) {
        int fds[2]; assert(pipe(fds)==0);
        int saved = dup(2); assert(saved>=0);
        assert(dup2(fds[1],2)==2); close(fds[1]);
        unsetenv("DARLING_CF_BINARY_PLIST_TRACE");
        unsetenv("DARLING_ARM64_PLIST_TRACE");
        errno=EDOM; assert(!reject() && errno==EDOM);
        setenv("DARLING_CF_BINARY_PLIST_TRACE","1",1);
        errno=ERANGE; assert(!reject() && errno==ERANGE);
        unsetenv("DARLING_CF_BINARY_PLIST_TRACE");
        setenv("DARLING_ARM64_PLIST_TRACE","1",1);
        errno=EINVAL; assert(!reject() && errno==EINVAL);
        close(2); errno=EDOM; assert(!reject() && errno==EDOM);
        assert(dup2(saved,2)==2); close(saved);
        char output[512]={0}; ssize_t length=read(fds[0],output,sizeof(output)-1);
        assert(length>0); close(fds[0]);
        const char *expected="CFBinaryPList.c:1234: rejected binary plist\\n"
                             "CFBinaryPList.c:1234: rejected binary plist\\n";
        assert(strcmp(output,expected)==0);
        puts("PASS opt-in rejection trace, default silence, legacy alias, return and errno preservation");
    }
  C
  out, status = Open3.capture2e('clang','-fsanitize=address,undefined',"#{dir}/test.c",'-o',"#{dir}/test")
  abort out unless status.success?
  out, status = Open3.capture2e("#{dir}/test")
  puts out
  abort 'trace regression failed' unless status.success?
end
