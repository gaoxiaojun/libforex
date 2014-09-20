cmake_minimum_required (VERSION 2.8.9)
project (LIBFOREX)

# Point CMake at any custom modules we may ship
set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

# Prefer our bundled versions of dependencies.
set(DEPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/.deps")
set(DEPS_BUILD_DIR "${DEPS_DIR}/build")
set(DEPS_INSTALL_DIR "${DEPS_DIR}/usr")
set(DEPS_BIN_DIR "${DEPS_INSTALL_DIR}/bin")

list(APPEND CMAKE_PREFIX_PATH ${DEPS_INSTALL_DIR})

set(LIBFOREX_VERSION_MAJOR 0)
set(LIBFOREX_VERSION_MINOR 0)
set(LIBFOREX_VERSION_PATCH 1)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_definitions(-Wall -Wextra -pedantic -Wno-unused-parameter
    -Wstrict-prototypes -std=gnu99)

add_definitions(-DHAVE_CONFIG_H)

if(CMAKE_BUILD_TYPE MATCHES Debug)
  # cmake automatically appends -g to the compiler flags
  set(DEBUG 1)
else()
  set(DEBUG 0)
  add_definitions(-DNDEBUG)
endif()

if(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--no-undefined")
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined")
  set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,--no-undefined")
endif()

include_directories("${PROJECT_BINARY_DIR}/config")
include_directories("${PROJECT_SOURCE_DIR}/src")
include_directories("${PROJECT_SOURCE_DIR}/src/lib")

# Modules used by platform auto-detection
include(CheckLibraryExists)

find_package(LibUV REQUIRED)
include_directories(SYSTEM ${LIBUV_INCLUDE_DIRS})

find_package(LuaJit REQUIRED)
include_directories(SYSTEM ${LUAJIT_INCLUDE_DIRS})

find_package(Jemalloc REQUIRED)
include_directories(SYSTEM ${JEMALLOC_INCLUDE_DIRS})

find_package(UUID REQUIRED)
include_directories(SYSTEM ${UUID_INCLUDE_DIRS})

include_directories(SYSTEM ${PROJECT_SOURCE_DIR}/include)

if (CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  include_directories(SYSTEM ${JEMALLOC_INCLUDE_DIRS}/msvc_compat)
endif()

if (CMAKE_COMPILER_IS_GNUCC OR CMAKE_C_COMPILER_ID STREQUAL "Clang")
  set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -std=gnu99" )
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

add_subdirectory(config)
add_subdirectory(src)
