cmake_minimum_required(VERSION 3.18.0 FATAL_ERROR)

# iOS Development requires clang
if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    message(FATAL_ERROR "This framework requires the use of clang.")
endif()

# Check iOS SDK Path
if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    # Find SDK Path
    execute_process(COMMAND xcrun --show-sdk-path --sdk iphoneos
        OUTPUT_VARIABLE XENEX_IOS_SDK
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
else()
    # Check for environment variable
    if (EXISTS $ENV{XENEX_IOS_SDK})
        set(XENEX_IOS_SDK $ENV{XENEX_IOS_SDK})
    else()
        message(FATAL_ERROR "Cannot find iOS SDK! Set the XENEX_IOS_SDK environment variable")
    endif()
endif()

# Configuration
set(CMAKE_OSX_ARCHITECTURES "arm64")
set(CMAKE_OSX_SYSROOT ${XENEX_IOS_SDK})

# Set output folder
set(XENEX_BIN_FOLDER ${CMAKE_BINARY_DIR}/xenex_bin)
if (NOT EXISTS ${XENEX_BIN_FOLDER})
    file(MAKE_DIRECTORY ${XENEX_BIN_FOLDER})
endif()

set(XENEX_ROOT ${CMAKE_CURRENT_LIST_DIR})

# Main setup macro
macro(xenex_setup target_app binary_name)
    if (NOT DEFINED XENEX_TARGET_APP)
        message(FATAL_ERROR "Define XENEX_TARGET_APP where the target IPA is located.")
    endif()

    if (NOT EXISTS "${XENEX_TARGET_APP}/Payload")
        message(FATAL_ERROR "Cannot find Payload folder. Place your IPA contents into the folder defined in XENEX_TARGET_APP.")
    endif()

    file(GLOB XENEX_APP_FOLDER "${XENEX_TARGET_APP}/Payload/*.app")

    if(XENEX_APP_FOLDER STREQUAL "")
        message(FATAL_ERROR "Unable to find application inside Payload folder.")
    endif()

    if (NOT DEFINED INJECTOR_BINARY_NAME)
        message(FATAL_ERROR "Unable to determine binary name. Define INJECTOR_BINARY_NAME.")
    endif()

    if (NOT EXISTS "${XENEX_APP_FOLDER}/${INJECTOR_BINARY_NAME}")
        message(FATAL_ERROR "Unable to find binary ${INJECTOR_BINARY_NAME} in application folder")
    endif()

    # Codegen target
    add_custom_target(InjectorCodegen ALL
        COMMAND mkdir -p ${XENEX_BIN_FOLDER}/IPA
        COMMAND python3 ${XENEX_ROOT}/patcher/patcher.py
            ${XENEX_APP_FOLDER}/${INJECTOR_BINARY_NAME}
            ${XENEX_BIN_FOLDER}
            ${INJECTOR_BINARY_NAME}
            ${CMAKE_CURRENT_SOURCE_DIR}
        WORKING_DIRECTORY ${XENEX_ROOT}/patcher
        COMMENT "Generating injection code"
        BYPRODUCTS ${XENEX_BIN_FOLDER}/bootloader.hpp
    )
    add_dependencies(${PROJECT_NAME} InjectorCodegen)

    # Include generated headers
    target_include_directories(${PROJECT_NAME} PRIVATE ${XENEX_BIN_FOLDER})
    target_link_options(${PROJECT_NAME} PRIVATE "-L${XENEX_IOS_SDK}/usr/lib")
endmacro()