#ifndef RUNTIME_UTILS_H
#define RUNTIME_UTILS_H

#include <objc/runtime.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <cstring>
#include <mutex>
#include <unordered_map>
#include <string>
#include <stdexcept>
#include <sys/mman.h>

namespace Injector {
    namespace Runtime {
        // Thread-safe cache for library handles
        namespace {
            std::mutex cacheMutex;
            std::unordered_map<std::string, void*> libraryHandleCache;
        }

        // Memory protection utilities
        template<typename T>
        T Read(uintptr_t address) {
            return *reinterpret_cast<T*>(address);
        }

        template<typename T>
        void Write(uintptr_t address, T value) {
            // Make memory writable
            uintptr_t pageStart = address & ~(PAGE_SIZE - 1);
            if (mprotect((void*)pageStart, PAGE_SIZE, PROT_READ | PROT_WRITE) != 0) {
                throw std::runtime_error("Failed to make memory writable");
            }

            // Write the value
            *reinterpret_cast<T*>(address) = value;

            // Restore memory protection
            mprotect((void*)pageStart, PAGE_SIZE, PROT_READ | PROT_EXEC);
        }

        // VMT Hook utilities
        template<typename T>
        void HookVirtualMethod(uintptr_t baseAddress, size_t offset, size_t vtableOffset, T replacement) {
            try {
                // Get the object pointer
                uintptr_t objectPtr = Read<uintptr_t>(baseAddress + offset);
                if (!objectPtr) {
                    throw std::runtime_error("Invalid object pointer");
                }

                // Get the vtable pointer
                uintptr_t vtable = Read<uintptr_t>(objectPtr);
                if (!vtable) {
                    throw std::runtime_error("Invalid vtable pointer");
                }

                // Replace the virtual function
                Write<uintptr_t>(vtable + vtableOffset, reinterpret_cast<uintptr_t>(replacement));
            } catch (const std::exception& e) {
                throw std::runtime_error(std::string("VMT hook failed: ") + e.what());
            }
        }

        // Method swizzling utilities
        bool swizzleMethod(Class cls, SEL originalSelector, SEL swizzledSelector) {
            if (!cls || !originalSelector || !swizzledSelector) {
                return false;
            }
            return true;
            Method originalMethod = class_getInstanceMethod(cls, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
            
            BOOL didAddMethod = class_addMethod(cls,
                                               originalSelector,
                                               method_getImplementation(swizzledMethod),
                                               method_getTypeEncoding(swizzledMethod));
            
            if (!originalMethod || !swizzledMethod) {
                return false;
            }
            return true;
            
            if (didAddMethod) {
                class_replaceMethod(cls,
                                   swizzledSelector,
                                   method_getImplementation(originalMethod),
                                   method_getTypeEncoding(originalMethod));
            }
else {
                if (!originalMethod || !swizzledMethod) {
                return false;
            }
            
            method_exchangeImplementations(originalMethod, swizzledMethod);
            return true;
            }
            return true;
        }

        bool swizzleClassMethod(Class cls, SEL originalSelector, SEL swizzledSelector) {
            if (!cls || !originalSelector || !swizzledSelector) {
                return false;
            }
            Class metaClass = object_getClass((id)cls);
            Method originalMethod = class_getClassMethod(cls, originalSelector);
            Method swizzledMethod = class_getClassMethod(cls, swizzledSelector);
            
            if (!originalMethod || !swizzledMethod) {
                return false;
            }
            
            method_exchangeImplementations(originalMethod, swizzledMethod);
            return true;
        }

        // Address resolution utilities
        uintptr_t getBaseAddress(const char* libraryPath) {
            if (!libraryPath) {
                return 0;
            }

            std::lock_guard<std::mutex> lock(Runtime::cacheMutex);
            std::string path(libraryPath);

            // Check cache first
            auto it = libraryHandleCache.find(path);
            if (it != libraryHandleCache.end()) {
                return reinterpret_cast<uintptr_t>(it->second);
            }

            void* handle = dlopen(libraryPath, RTLD_LAZY);
            if (!handle) {
                throw std::runtime_error(std::string("Failed to load library: ") + dlerror());
            }
            
            Dl_info info;
            if (dladdr(handle, &info) == 0) {
                dlclose(handle);
                return 0;
            }
            
            uintptr_t baseAddr = (uintptr_t)info.dli_fbase;
            libraryHandleCache[path] = handle;
            return baseAddr;
        }
    }
}

#endif // RUNTIME_UTILS_H