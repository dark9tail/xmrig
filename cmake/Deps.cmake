# Optional dependency bootstrap for local builds.
#
# XMRig can use dependencies prebuilt into the repository-local deps/
# directory.  When XMRIG_AUTO_BUILD_DEPS is enabled, CMake will invoke the
# existing scripts to populate deps/ before running find_package().

option(XMRIG_AUTO_BUILD_DEPS "Build bundled dependencies into deps/ when missing" ON)

if (NOT XMRIG_DEPS AND EXISTS "${CMAKE_SOURCE_DIR}/deps")
    set(XMRIG_DEPS "${CMAKE_SOURCE_DIR}/deps" CACHE PATH "Path to prebuilt XMRig dependencies" FORCE)
endif()

function(xmrig_build_dep name script header library)
    if (NOT XMRIG_AUTO_BUILD_DEPS)
        return()
    endif()

    if (NOT XMRIG_DEPS)
        set(XMRIG_DEPS "${CMAKE_SOURCE_DIR}/deps" CACHE PATH "Path to prebuilt XMRig dependencies" FORCE)
    endif()

    if (EXISTS "${XMRIG_DEPS}/include/${header}" AND EXISTS "${XMRIG_DEPS}/lib/${library}")
        return()
    endif()

    message(STATUS "${name} not found in ${XMRIG_DEPS}; building bundled dependency with ${script}")
    execute_process(
        COMMAND /bin/sh -e "${CMAKE_SOURCE_DIR}/${script}"
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        RESULT_VARIABLE XMRIG_DEP_RESULT
    )

    if (NOT XMRIG_DEP_RESULT EQUAL 0)
        message(FATAL_ERROR "Failed to build ${name}; install it system-wide, set XMRIG_DEPS, or rerun with -DXMRIG_AUTO_BUILD_DEPS=OFF")
    endif()
endfunction()

xmrig_build_dep("libuv" "scripts/build.uv.sh" "uv.h" "libuv.a")

if (WITH_HWLOC AND NOT CMAKE_CXX_COMPILER_ID MATCHES MSVC)
    xmrig_build_dep("hwloc" "scripts/build.hwloc.sh" "hwloc.h" "libhwloc.a")
endif()
