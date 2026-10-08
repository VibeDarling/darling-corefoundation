CFURLComponents.c/.h, CFURLComponents_URIParser.c, CFURLComponents_Internal.h
and CFOverflow.h are reused from Apple swift-corelibs-foundation commit
a656bb7b3d3fbf33ff273e37dd4a78c9011bd4fa, CoreFoundation/URL.subproj and
CoreFoundation/Base.subproj. Original Apache-2.0-with-runtime-exception license
notices remain in each file. No Apple binary implementation was inspected.

The only implementation adaptations use the existing CFRuntime.h, CF_EXPORT,
and dispatch_once/_CFRuntimeRegisterClass pattern from CFArray.c in this tree;
the newer Swift runtime's fixed type ID is unavailable here.

query.c tests the real backend without NSURLQueryItem or private Messages APIs.
Compile with this checkout's CF prefix/macros and pinned Darling SDK headers,
then link CFURLComponents.c and CFURLComponents_URIParser.c with CoreFoundation,
libSystem and libobjc. All configure/compile/link work must hold the shared
Darling heavy-build lock. The paired Foundation test/urlcomponents-query/build.py
records the full focused commands and builds this guest executable.

These two pure C sources compile as C. The older repository default forces all
CF sources into Objective-C and imports the full Foundation umbrella; that is
unnecessary for this backend and causes a circular header dependency with its
Foundation wrapper. The per-source CMake setting uses the same language as the
focused compile and the published sources.
