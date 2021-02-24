cmake_minimum_required (VERSION 3.19)
include_guard(GLOBAL)

include(CMakePackageConfigHelpers) # https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html
include(CMakeDependentOption) # https://cmake.org/cmake/help/latest/module/CMakeDependentOption.html

include(FeatureSummary) # https://cmake.org/cmake/help/latest/module/FeatureSummary.html
#set(FeatureSummary_DEFAULT_PKG_TYPE REQUIRED CACHE INTERNAL "" FORCE)
include(CMakePrintHelpers) # https://cmake.org/cmake/help/latest/module/CMakePrintHelpers.html

set_property(GLOBAL PROPERTY USE_FOLDERS ON) # Enable folder layout as source layout in IDEs supporting it # https://cmake.org/cmake/help/latest/prop_gbl/USE_FOLDERS.html
set_property(GLOBAL PROPERTY REPORT_UNDEFINED_PROPERTIES "${CMAKE_BINARY_DIR}/undef_properties.log")

# Disable language extensions
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_CXX_EXTENSIONS OFF)

# A bit of CMake setup
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON CACHE INTERNAL "Disable building in source directory." FORCE) # undocumented
set(CMAKE_DISABLE_SOURCE_CHANGES ON CACHE INTERNAL "Disable changes to sources" FORCE) # undocumented
#if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
#  message(FATAL_ERROR "In-source builds are not allowed.")
#endif()

set(GLOBAL_DEPENDS_NO_CYCLES ON CACHE INTERNAL "Disallow cyclic dependencies between all targets" FORCE) # https://cmake.org/cmake/help/latest/prop_gbl/GLOBAL_DEPENDS_NO_CYCLES.html
#set(CMAKE_MESSAGE_CONTEXT_SHOW ON CACHE INTERNAL "Show message context" FORCE) # https://cmake.org/cmake/help/latest/variable/CMAKE_MESSAGE_CONTEXT_SHOW.html#variable:CMAKE_MESSAGE_CONTEXT_SHOW

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE INTERNAL "Default installation prefix!" FORCE)
endif()

## CMakeJSON Setup
set(CMakeJSON_MSG_ERROR_TYPE SEND_ERROR CACHE INTERNAL "CMakeJSON erro message type! (DEFAULT: SEND_ERROR)")
set(CMakeJSON_MSG_WARNING_TYPE SEND_ERROR CACHE INTERNAL "CMakeJSON warning message type!  (DEFAULT: SEND_ERROR)")
set(CMakeJSON_MSG_VERBOSE_TYPE VERBOSE CACHE INTERNAL "CMakeJSON VERBOSE message type! (DEFAULT: VERBOSE)")
mark_as_advanced(CMakeJSON_MSG_ERROR_TYPE CMakeJSON_MSG_WARNING_TYPE CMakeJSON_MSG_VERBOSE_TYPE)


option(CMakeJSON_DEBUG "Enable additional debug messages from CMakeJSON" OFF)
cmake_dependent_option(CMakeJSON_DEBUG_RETURN_PARENT "Print variables set to PARENT_SCOPE in cmakejson_return_to_parent_scope (very noise)" ON "CMakeJSON_DEBUG" OFF)
cmake_dependent_option(CMakeJSON_DEBUG_HELPERS "Print debug message from helper." ON "CMakeJSON_DEBUG" OFF)
cmake_dependent_option(CMakeJSON_DEBUG_RANGE_LOOP "Print debug message from range loop." ON "CMakeJSON_DEBUG" OFF)
cmake_dependent_option(CMakeJSON_DEBUG_PARSE "Enable additional debug messages while parsing JSON" ON "CMakeJSON_DEBUG" OFF)
cmake_dependent_option(CMakeJSON_DEBUG_PROJECT "Enable additional debug messages while creating projects/components" ON "CMakeJSON_DEBUG" OFF)
cmake_dependent_option(CMakeJSON_DEBUG_PROJECT_OPTIONS "Enable additional debug messages while creating project options" ON "CMakeJSON_DEBUG" OFF)
cmake_dependent_option(CMakeJSON_DEBUG_TARGET "Enable additional debug messages while creating targets" ON "CMakeJSON_DEBUG" OFF)
if(CMakeJSON_DEBUG)
    set(CMAKE_MESSAGE_CONTEXT_SHOW ON) # Locally override user value
endif()
mark_as_advanced(CMakeJSON_DEBUG
                 CMakeJSON_DEBUG_RETURN_PARENT
                 CMakeJSON_DEBUG_PARSE
                 CMakeJSON_DEBUG_PROJECT
                 CMakeJSON_DEBUG_PROJECT_OPTIONS
                 CMakeJSON_DEBUG_TARGET
)

# Include all CMakeJSON files
set(cmakejson_cmake_files)
list(APPEND cmakejson_cmake_files
    Helpers
    ValidateJSON
    ParseJSON
    Project
    Target
)

foreach(_file IN LISTS cmakejson_cmake_files)
    include("${CMAKE_CURRENT_LIST_DIR}/CMakeJSON_${_file}.cmake")
endforeach()
unset(cmakejson_cmake_files)