cmake_minimum_required(VERSION 3.19)




# Include CMakeJSON
set(CMakeJSON_BASE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../CMakeJSON")
list(APPEND CMAKE_MODULE_PATH "${CMakeJSON_BASE_PATH}")

# Use automatic setup.
# TODO: Decide wether to make this the default. 
set(CMakeJSON_ENABLE_PROJECT_OVERRIDE ON) # defines a macro called project() to silence a CMake Warning
set(CMakeJSON_USE_PROJECT_OVERRIDE ON)    # make the macro do something different from CMake. (i.e. accept a file name)

include(CMakeJSON)

### For debugging of CMakeJSON
set(CMakeJSON_DEBUG_PARSE OFF)
set(CMakeJSON_DEBUG_RETURN_PARENT OFF)
###

project("Simple.Project.json")

### The below is not needed for the example and just used for internal debugging of the examples

# Just for debugging:
if(CMakeJSON_DEBUG)
    add_library(ImportedTEST IMPORTED UNKNOWN)
    get_directory_property(BUILDSYSTEM_TARGETS BUILDSYSTEM_TARGETS)
    cmake_print_variables(BUILDSYSTEM_TARGETS)
    #get_directory_property(MACROS MACROS)
    #cmake_print_variables(MACROS)
    get_directory_property(VARS VARIABLES)
    cmake_print_variables(VARS)
    #foreach(var IN LISTS VARS)
    #    cmake_print_variables(${var})
    #endforeach()
endif()