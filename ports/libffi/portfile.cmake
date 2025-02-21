set(VERSION 3.4.2)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libffi/libffi
    REF v${VERSION}
    SHA512 d399319efcca375fe901b05722e25eca31d11a4261c6a5d5079480bbc552d4e4b42de2026912689d3b2f886ebb3c8bebbea47102e38a2f6acbc526b8d5bba388
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libffiConfig.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFFI_CONFIG_FILE=${CMAKE_CURRENT_LIST_DIR}/fficonfig.h
    OPTIONS_DEBUG
        -DFFI_SKIP_HEADERS=ON
)

vcpkg_install_cmake()

# Create pkgconfig file
set(PACKAGE_VERSION ${VERSION})
set(prefix "${CURRENT_INSTALLED_DIR}")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(toolexeclibdir "\${libdir}")
set(includedir "\${prefix}/include")
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    configure_file("${SOURCE_PATH}/libffi.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libffi.pc" @ONLY)
endif()
# debug
set(prefix "${CURRENT_INSTALLED_DIR}/debug")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(toolexeclibdir "\${libdir}")
set(includedir "\${prefix}/../include")
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    configure_file("${SOURCE_PATH}/libffi.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libffi.pc" @ONLY)
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()
if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libffi.pc
        "-lffi" "-llibffi")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libffi.pc
        "-lffi" "-llibffi")
endif()
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/ffi.h
        "   *know* they are going to link with the static library.  */"
        "   *know* they are going to link with the static library.  */

#define FFI_BUILDING
"
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
