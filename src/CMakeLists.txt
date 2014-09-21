set(CMAKE_INCLUDE_CURRENT_DIR ON)

file(GLOB LIBFX_SOURCE *.c)

add_library(libfx SHARED ${LIBFX_SOURCE})
add_library(libfx_static STATIC ${LIBFX_SOURCE})

target_link_libraries(libfx ${LIBUV_LIBRARIES} ${JEMALLOC_LIBRARIES})
target_link_libraries(libfx_static ${LIBUV_LIBRARIES} ${JEMALLOC_LIBRARIES})

set_target_properties(libfx PROPERTIES VERSION ${LIBTWSCLIENT_VERSION} SOVERSION ${LIBTWSCLIENT_PATCH})
set_target_properties(libfx PROPERTIES CLEAN_DIRECT_OUTPUT 1)
set_target_properties(libfx_static PROPERTIES CLEAN_DIRECT_OUTPUT 1)
set_target_properties(libfx_static PROPERTIES OUTPUT_NAME "libfx")

install(TARGETS libfx libfx_static
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
    ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)
