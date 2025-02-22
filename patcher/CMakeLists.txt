cmake_minimum_required(VERSION 3.10)
project(xenex)

# Set iOS platform
set(CMAKE_SYSTEM_NAME iOS)
set(CMAKE_OSX_SYSROOT /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.2.sdk)
set(CMAKE_OSX_ARCHITECTURES arm64)
set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE NO)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build as a dynamic library
add_library(xenex SHARED
    runtime_utils.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../fishhook.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../fishhook.h
)

# Include directories
target_include_directories(xenex PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}
)

# Set visibility flags for iOS
target_compile_options(xenex PRIVATE
    -fvisibility=hidden
)

# Link against required frameworks
target_link_libraries(xenex
    "-framework Foundation"
    "-framework UIKit"
)

# Set output name to .dylib
set_target_properties(xenex PROPERTIES
    SUFFIX ".dylib"
    PREFIX ""
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
    XCODE_ATTRIBUTE_DEVELOPMENT_TEAM ""
    XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO"
    XCODE_ATTRIBUTE_CODE_SIGN_STYLE "Automatic"
)