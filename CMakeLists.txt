cmake_minimum_required (VERSION 3.0)

project (LIBFOREX)

set(LIBFOREX_VERSION_MAJOR 0)
set(LIBFOREX_VERSION_MINOR 0)
set(LIBFOREX_VERSION_MICRO 1)
set(LIBFOREX_VERSION_PATCH 0)

set(LIBFOREX_VERSION "${LIBFOREX_MAJOR}.${LIBFOREX_MINOR}.${LIBFOREX_MICRO}")

# Point CMake at any custom modules we may ship
set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

# Prefer our bundled versions of dependencies.
set(DEPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/.deps")
set(DEPS_BUILD_DIR "${DEPS_DIR}/build")
set(DEPS_INSTALL_DIR "${DEPS_DIR}/usr")
set(DEPS_BIN_DIR "${DEPS_INSTALL_DIR}/bin")

list(APPEND CMAKE_PREFIX_PATH ${DEPS_INSTALL_DIR})

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif(NOT CMAKE_BUILD_TYPE)

if (NOT (CMAKE_COMPILER_IS_GNUCC OR (${CMAKE_C_COMPILER_ID} STREQUAL "AppleClang")))
    message(FATAL_ERROR "Compiler must be gcc or clang")
endif()

add_definitions(-Wall -Wextra -Wshadow -pedantic -Wno-unused-parameter -Wstrict-prototypes -std=gnu99)
add_definitions(-fvisibility=hidden)

add_definitions(-DHAVE_CONFIG_H)

if(CMAKE_BUILD_TYPE MATCHES Debug)
  set(DEBUG 1)
else()
  set(DEBUG 0)
endif()

# Modules used by platform auto-detection
include(CheckLibraryExists)

find_package(LibUV REQUIRED)
include_directories(SYSTEM ${LIBUV_INCLUDE_DIRS})

find_package(LuaJit REQUIRED)
include_directories(SYSTEM ${LUAJIT_INCLUDE_DIRS})

find_package(JEMalloc REQUIRED)
include_directories(SYSTEM ${JEMALLOC_INCLUDE_DIRS})

find_package(UUID REQUIRED)
include_directories(SYSTEM ${UUID_INCLUDE_DIRS})

include_directories(SYSTEM ${PROJECT_SOURCE_DIR}/include)

if (WIN32)
  include_directories(SYSTEM ${PROJECT_SOURCE_DIR}/msvc_compat)
endif()

include_directories("${PROJECT_BINARY_DIR}/config")
include_directories("${PROJECT_SOURCE_DIR}/src")
include_directories("${PROJECT_SOURCE_DIR}/src/lib")

add_subdirectory(config)
