# - Try to find uuid library
# Once done this will define
#  UUID_FOUND - System has uuid
#  UUID_INCLUDE_DIRS - The uuid include directories
#  UUID_LIBRARIES - The libraries needed to use uuid

find_package(PkgConfig)
if(NOT UUID_USE_BUNDLED)
  find_package(PkgConfig)
  if (PKG_CONFIG_FOUND)
    pkg_check_modules(PC_UUID QUIET UUID)
  endif()
else()
  set(PC_UUID_INCLUDEDIR)
  set(PC_UUID_INCLUDE_DIRS)
  set(PC_UUID_LIBDIR)
  set(PC_UUID_LIBRARY_DIRS)
  set(LIMIT_SEARCH NO_DEFAULT_PATH)
endif()

set(UUID_DEFINITIONS ${PC_UUID_CFLAGS_OTHER})

find_path(UUID_INCLUDE_DIR uuid.h
          PATHS ${PC_UUID_INCLUDEDIR} ${PC_UUID_INCLUDE_DIRS}
          PATH_SUFFIXES uuid
          ${LIMIT_SEARCH})

# If we're asked to use static linkage, add uuid.a as a preferred library name.
if(UUID_USE_STATIC)
  list(APPEND UUID_NAMES
    "${CMAKE_STATIC_LIBRARY_PREFIX}uuid${CMAKE_STATIC_LIBRARY_SUFFIX}")
endif()

list(APPEND UUID_NAMES UUID)

find_library(UUID_LIBRARY NAMES ${UUID_NAMES}
             PATHS ${PC_UUID_LIBDIR} ${PC_UUID_LIBRARY_DIRS}
             ${LIMIT_SEARCH})

set(UUID_LIBRARIES ${UUID_LIBRARY})
set(UUID_INCLUDE_DIRS ${UUID_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set UUID_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(UUID DEFAULT_MSG
                                  UUID_LIBRARY UUID_INCLUDE_DIR)

mark_as_advanced(UUID_INCLUDE_DIR UUID_LIBRARY)
