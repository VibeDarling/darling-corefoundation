#include <CoreFoundation/CFURLComponents.h>
#include <CoreFoundation/CFArray.h>
#include <CoreFoundation/CFDictionary.h>
#include <stdio.h>

int main(void) {
    CFURLComponentsRef components = _CFURLComponentsCreateWithString(kCFAllocatorDefault,
        CFSTR("https://example.invalid/path?name=a%20b&flag&empty=&name=second"));
    if (!components) return 1;
    CFArrayRef items = _CFURLComponentsCopyQueryItems(components);
    if (!items || CFArrayGetCount(items) != 4) return 1;
    const CFStringRef names[] = { CFSTR("name"), CFSTR("flag"), CFSTR("empty"), CFSTR("name") };
    const CFStringRef values[] = { CFSTR("a b"), NULL, CFSTR(""), CFSTR("second") };
    for (CFIndex i = 0; i < 4; ++i) {
        CFDictionaryRef pair = CFArrayGetValueAtIndex(items, i);
        CFStringRef name = CFDictionaryGetValue(pair, _kCFURLComponentsNameKey);
        CFStringRef value = CFDictionaryGetValue(pair, _kCFURLComponentsValueKey);
        if (!name || !CFEqual(name, names[i]) ||
            (values[i] ? !value || !CFEqual(value, values[i]) : value != NULL)) return 1;
    }
    CFRelease(items);
    _CFURLComponentsSetPercentEncodedQuery(components, CFSTR(""));
    items = _CFURLComponentsCopyQueryItems(components);
    if (!items || CFArrayGetCount(items) != 0) return 1;
    CFRelease(items);
    _CFURLComponentsSetPercentEncodedQuery(components, NULL);
    if (_CFURLComponentsCopyQueryItems(components) != NULL) return 1;
    CFRelease(components);
    puts("PASS CFURLComponents ordered decoded query; absent/empty values and queries");
    return 0;
}
