cmake_minimum_required(VERSION 3.10)
project(fishhook)

# Set C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Add source files
add_library(fishhook STATIC
    fishhook.c
    fishhook.h
)

# Include directories
target_include_directories(fishhook PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Set visibility flags for macOS/iOS
target_compile_options(fishhook PRIVATE
    -fvisibility=hidden
)

# Set installation rules
install(TARGETS fishhook
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
install(FILES fishhook.h
    DESTINATION include
)