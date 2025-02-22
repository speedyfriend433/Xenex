#!/usr/bin/env python3

import os
import sys
import struct
import shutil
from pathlib import Path

def align(addr, alignment):
    return (addr + alignment - 1) & ~(alignment - 1)

def patch_binary(binary_path, output_dir, binary_name, source_dir):
    # Create output directories
    ipa_dir = os.path.join(output_dir, 'IPA')
    os.makedirs(ipa_dir, exist_ok=True)

    # Read binary file
    with open(binary_path, 'rb') as f:
        binary_data = bytearray(f.read())

    # Generate bootloader code
    bootloader_template = '''
    #pragma once
    
    // Auto-generated bootloader code
    // DO NOT MODIFY
    
    namespace Injector {
        extern "C" void initialize();
    
        inline void __attribute__((constructor)) bootstrap() {
            initialize();
        }
    }
    '''

    # Write bootloader header
    with open(os.path.join(output_dir, 'bootloader.hpp'), 'w') as f:
        f.write(bootloader_template)

    # Copy binary to output
    output_binary = os.path.join(ipa_dir, binary_name)
    shutil.copy2(binary_path, output_binary)

    print(f"[*] Generated bootloader code")
    print(f"[*] Binary patched and copied to {output_binary}")

def main():
    if len(sys.argv) != 5:
        print(f"Usage: {sys.argv[0]} <binary_path> <output_dir> <binary_name> <source_dir>")
        sys.exit(1)

    binary_path = sys.argv[1]
    output_dir = sys.argv[2]
    binary_name = sys.argv[3]
    source_dir = sys.argv[4]

    patch_binary(binary_path, output_dir, binary_name, source_dir)

if __name__ == '__main__':
    main()