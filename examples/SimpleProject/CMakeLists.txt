cmake_minimum_required(VERSION 3.19)

# Include CMakeJSON
set(CMakeJSON_BASE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../CMakeJSON")
list(APPEND CMAKE_MODULE_PATH "${CMakeJSON_BASE_PATH}")

# Use automatic setup.
# TODO: Decide wether to make this the default. 
set(CMakeJSON_ENABLE_PROJECT_OVERRIDE ON) # defines a macro called project() to silence a CMake Warning
set(CMakeJSON_USE_PROJECT_OVERRIDE ON)    # make the macro do something different from CMake. (i.e. accept a file name)

include(CMakeJSON)

project("Simple.Project.json")