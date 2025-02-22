# Xenex

A powerful framework for injecting custom code into iOS applications, providing advanced runtime manipulation capabilities including method swizzling, VMT hooking, and memory protection utilities.

## Features

- **Method Swizzling**: Runtime method replacement and interception
- **VMT Hooking**: Virtual method table manipulation for C++ classes
- **Memory Protection**: Safe memory read/write operations with automatic protection handling
- **Dynamic Library Loading**: Thread-safe library handle caching and management
- **Address Resolution**: Utilities for resolving base addresses and function pointers

## Requirements

- CMake build system
- iOS SDK
- Decrypted target application (DRM-free)
- Compatible iOS architecture

## Setup

1. Add this repository to your CMake project:
```cmake
add_subdirectory(xenex)
```

2. Include the Injector.cmake in your CMakeLists.txt:
```cmake
include(${CMAKE_CURRENT_LIST_DIR}/xenex/Xenex.cmake)
```

## Usage

### Basic Injection

1. Create your injection code in a C++ file (e.g., `injection.cpp`):
```cpp
namespace Xenex {
    extern "C" void initialize() {
        // Your injection code here
        // This will be called when the app starts
    }
}
```

2. Set up your CMake target:
```cmake
# Define your target
add_library(MyInjection SHARED
    injection.cpp
)

# Configure injection
set(XENEX_BINARY_NAME "YourApp") # Name of the target app binary
set(XENEX_APP_FOLDER "path/to/Payload/YourApp.app") # Path to the app bundle
set(XENEX_BIN_FOLDER "${CMAKE_BINARY_DIR}/bin") # Output directory

# Apply injection configuration
configure_xenex(MyInjection)
```

### Advanced Features

#### Method Swizzling
```cpp
// Swizzle instance method
Class targetClass = objc_getClass("TargetClass");
SEL originalSelector = @selector(originalMethod);
SEL swizzledSelector = @selector(swizzledMethod);
Xenex::Runtime::swizzleMethod(targetClass, originalSelector, swizzledSelector);

// Swizzle class method
Xenex::Runtime::swizzleClassMethod(targetClass, originalSelector, swizzledSelector);
```

#### VMT Hooking
```cpp
// Hook virtual method
uintptr_t baseAddress = 0x1000000;
size_t offset = 0x100;
size_t vtableOffset = 0x10;
Xenex::Runtime::HookVirtualMethod(baseAddress, offset, vtableOffset, replacementFunction);
```

#### Memory Operations
```cpp
// Read memory
auto value = Xenex::Runtime::Read<uint32_t>(address);

// Write memory (with automatic protection handling)
Xenex::Runtime::Write<uint32_t>(address, newValue);
```

## Build Process

1. Build your project using CMake
2. The patcher will automatically:
   - Generate a bootloader
   - Patch the target binary
   - Create an IPA folder with the modified binary
3. Find the patched binary in `${XENEX_BIN_FOLDER}/IPA/`

## Example

Check the `example/` directory for a complete working example demonstrating various injection techniques.

## Security Considerations

- Always backup the original app binary before patching
- Ensure proper memory protection when modifying code segments
- Be cautious with method swizzling to avoid runtime crashes
- Verify target app architecture compatibility
- Remove any DRM protection before patching

## Troubleshooting

- Verify the target app is properly decrypted
- Check architecture compatibility between injection code and target app
- Ensure all memory addresses are properly aligned
- Validate method signatures when using swizzling

## License

This project is licensed under the MIT License - see the LICENSE file for details.