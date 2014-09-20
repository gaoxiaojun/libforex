# This is not meant to be included by the top-level.
cmake_minimum_required (VERSION 2.8.7)
project(SKYWALKER_DEPS)

if(NOT DEPS_DIR)
  get_filename_component(PARENT_DIR ${CMAKE_CURRENT_SOURCE_DIR} PATH)
  set(DEPS_DIR ${PARENT_DIR}/.deps)
endif()

set(DEPS_INSTALL_DIR "${DEPS_DIR}/usr")
set(DEPS_BIN_DIR "${DEPS_DIR}/usr/bin")
set(DEPS_LIB_DIR "${DEPS_DIR}/usr/lib")
set(DEPS_BUILD_DIR "${DEPS_DIR}/build")
set(DEPS_DOWNLOAD_DIR "${DEPS_BUILD_DIR}/downloads")

option(USE_BUNDLED "Use bundled dependencies." ON)

option(USE_BUNDLED_LIBUV "Use the bundled libuv." ${USE_BUNDLED})
option(USE_BUNDLED_LUAJIT "Use the bundled version of luajit." ${USE_BUNDLED})
option(USE_BUNDLED_JEMALLOC "Use the bundled version of jemalloc." ${USE_BUNDLED})
option(USE_BUNDLED_UUID "Use the bundled version of uuid." ${USE_BUNDLED})

# TODO: add windows support

find_program(MAKE_PRG NAMES gmake make)
if(MAKE_PRG)
  execute_process(
    COMMAND "${MAKE_PRG}" --version
    OUTPUT_VARIABLE MAKE_VERSION_INFO)
  if(NOT "${OUTPUT_VARIABLE}" MATCHES ".*GNU.*")
    unset(MAKE_PRG)
  endif()
endif()
if(NOT MAKE_PRG)
  message(FATAL_ERROR "GNU Make is required to build the dependencies.")
else()
  message(STATUS "Found GNU Make at ${MAKE_PRG}")
endif()

# When using make, use the $(MAKE) variable to avoid warning about the job
# server.
if(CMAKE_GENERATOR MATCHES "Makefiles")
  set(MAKE_PRG "$(MAKE)")
endif()


include(ExternalProject)

set(LIBUV_URL https://github.com/joyent/libuv/archive/v0.11.29.tar.gz)
set(LIBUV_MD5 907dafd14c78d5490c2b8796a3ea9edf)

set(LUAJIT_URL http://luajit.org/download/LuaJIT-2.0.3.tar.gz)
set(LUAJIT_MD5 f14e9104be513913810cd59c8c658dc0)

set(JEMALLOC_URL http://www.canonware.com/download/jemalloc/jemalloc-3.6.0.tar.bz2)
set(JEMALLOC_MD5 e76665b63a8fddf4c9f26d2fa67afdf2)

set(UUID_URL https://github.com/gaoxiaojun/uuid/archive/v1.0.tar.gz)
set(UUID_MD5 27120a6f0b1b4beb31279e48c8280c34)


if(USE_BUNDLED_LIBUV)
  ExternalProject_Add(libuv
    PREFIX ${DEPS_BUILD_DIR}
    URL ${LIBUV_URL}
    URL_MD5 ${LIBUV_MD5}
    DOWNLOAD_DIR ${DEPS_DOWNLOAD_DIR}/libuv
    DOWNLOAD_COMMAND ${CMAKE_COMMAND}
      -DPREFIX=${DEPS_BUILD_DIR}
      -DDOWNLOAD_DIR=${DEPS_DOWNLOAD_DIR}/libuv
      -DURL=${LIBUV_URL}
      -DEXPECTED_MD5=${LIBUV_MD5}
      -DTARGET=libuv
      -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/DownloadAndExtractFile.cmake
    CONFIGURE_COMMAND sh ${DEPS_BUILD_DIR}/src/libuv/autogen.sh &&
      ${DEPS_BUILD_DIR}/src/libuv/configure --with-pic --disable-shared
        --prefix=${DEPS_INSTALL_DIR} CC=${CMAKE_C_COMPILER}
    INSTALL_COMMAND ${MAKE_PRG} install)
  list(APPEND THIRD_PARTY_DEPS libuv)
endif()

if(USE_BUNDLED_LUAJIT)
  ExternalProject_Add(luajit
    PREFIX ${DEPS_BUILD_DIR}
    URL ${LUAJIT_URL}
    URL_MD5 ${LUAJIT_MD5}
    DOWNLOAD_DIR ${DEPS_DOWNLOAD_DIR}/luajit
    DOWNLOAD_COMMAND ${CMAKE_COMMAND}
      -DPREFIX=${DEPS_BUILD_DIR}
      -DDOWNLOAD_DIR=${DEPS_DOWNLOAD_DIR}/luajit
      -DURL=${LUAJIT_URL}
      -DEXPECTED_MD5=${LUAJIT_MD5}
      -DTARGET=luajit
      -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/DownloadAndExtractFile.cmake
    CONFIGURE_COMMAND ""
    BUILD_IN_SOURCE 1
    BUILD_COMMAND ""
    INSTALL_COMMAND ${MAKE_PRG} CC=${CMAKE_C_COMPILER}
                                PREFIX=${DEPS_INSTALL_DIR}
                                CFLAGS=-fPIC
                                BUILDMODE=static
                                install)
  list(APPEND THIRD_PARTY_DEPS luajit)
endif()

if(USE_BUNDLED_JEMALLOC)
  ExternalProject_Add(jemalloc
    PREFIX ${DEPS_BUILD_DIR}
    URL ${JEMALLOC_URL}
    URL_MD5 ${JEMALLOC_MD5}
    DOWNLOAD_DIR ${DEPS_DOWNLOAD_DIR}/jemalloc
    DOWNLOAD_COMMAND ${CMAKE_COMMAND}
      -DPREFIX=${DEPS_BUILD_DIR}
      -DDOWNLOAD_DIR=${DEPS_DOWNLOAD_DIR}/jemalloc
      -DURL=${JEMALLOC_URL}
      -DEXPECTED_MD5=${JEMALLOC_MD5}
      -DTARGET=jemalloc
      -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/DownloadAndExtractFile.cmake
    CONFIGURE_COMMAND sh ${DEPS_BUILD_DIR}/src/jemalloc/configure --enable-debug
        --prefix=${DEPS_INSTALL_DIR} --enable-cc-silence CC=${CMAKE_C_COMPILER}
    INSTALL_COMMAND ${MAKE_PRG} install)
  list(APPEND THIRD_PARTY_DEPS jemalloc)
endif()

if(USE_BUNDLED_UUID)
  ExternalProject_Add(uuid
    PREFIX ${DEPS_BUILD_DIR}
    URL ${UUID_URL}
    URL_MD5 ${UUID_MD5}
    DOWNLOAD_DIR ${DEPS_DOWNLOAD_DIR}/uuid
    DOWNLOAD_COMMAND ${CMAKE_COMMAND}
      -DPREFIX=${DEPS_BUILD_DIR}
      -DDOWNLOAD_DIR=${DEPS_DOWNLOAD_DIR}/uuid
      -DURL=${UUID_URL}
      -DEXPECTED_MD5=${UUID_MD5}
      -DTARGET=uuid
      -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/DownloadAndExtractFile.cmake
   CMAKE_GENERATOR "${CMAKE_GENERATOR}"
   CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${DEPS_INSTALL_DIR}
   )
  list(APPEND THIRD_PARTY_DEPS uuid)
endif()

add_custom_target(third-party ALL
  COMMAND ${CMAKE_COMMAND} -E touch .third-party
  DEPENDS ${THIRD_PARTY_DEPS})
