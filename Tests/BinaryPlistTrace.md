# Binary-plist rejection diagnostics

Set `DARLING_CF_BINARY_PLIST_TRACE=1` before starting the program to emit a
source-line diagnostic to stderr whenever the binary parser takes a `FAIL_FALSE`
path. `DARLING_ARM64_PLIST_TRACE` remains an alias for older local workflows.
Presence enables either variable (including an empty value); unset both to
disable tracing. No input contents are logged. This is a debugging aid, not a
stable error API, a change to plist acceptance, or coverage of every rejection
path (`FAIL_MAXOFFSET` and direct returns are unchanged).

The implementation is Darling-only and preserves errno even when stderr is
closed. It uses a bounded stack buffer and a direct write, not CF formatting or
logging that might re-enter the parser. Line numbers vary with the source tree.

Run `ruby Tests/BinaryPlistTrace.rb` with clang installed. The test extracts the
actual helper and FAIL_FALSE macro and runs under ASan/UBSan. It checks silent
default behavior, both variable names, exact line reporting, false return, and
errno preservation with open and closed stderr. This is helper/macro coverage,
not an end-to-end malformed-plist corpus test. The changed CFBinaryPList.c also
compiles as an ARM64 Mach-O object with the staged Darling SDK/build recipe;
no clean whole-framework or x86 runtime build is claimed.
