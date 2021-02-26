cmake_minimum_required(VERSION 3.19)

# Include CMakeJSON
# TODO: Decide wether to make this the default. 
set(CMakeJSON_ENABLE_PROJECT_OVERRIDE ON) # defines a macro called project() to silence a CMake Warning
set(CMakeJSON_DEBUG ON) # TODO: Remove this line later and turn off debugging by default!
set(CMakeJSON_DEBUG_PARSE OFF)
set(CMakeJSON_DEBUG_RANGE_LOOP OFF)
set(CMakeJSON_DEBUG_HELPERS OFF)
set(CMakeJSON_DEBUG_RETURN_PARENT OFF)
set(CMakeJSON_DEBUG_PROJECT OFF)
set(CMakeJSON_DEBUG_PROJECT_OPTIONS ON)
set(CMakeJSON_DEBUG_PROJECT_DEPENDENCIES OFF)
set(CMakeJSON_DEBUG_TARGET OFF)
include("${CMAKE_CURRENT_SOURCE_DIR}/../../CMakeJSON/CMakeJSON.cmake")
project("Simple.Project.json")

feature_summary(WHAT ALL) # Purely optional.
