cmake_minimum_required(VERSION 3.19)

# Use automatic setup.
# TODO: Decide wether to make this the default. 
set(CMakeJSON_ENABLE_PROJECT_OVERRIDE ON) # defines a macro called project() to silence a CMake Warning

# Include CMakeJSON
set(CMakeJSON_BASE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../CMakeJSON")
list(APPEND CMAKE_MODULE_PATH "${CMakeJSON_BASE_PATH}")
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../prefix/")

include(CMakeJSON)
# include("${CMakeJSON_BASE_PATH}/CMakeJSON.cmake") # This does not require setting CMAKE_MODULE_PATH

### For debugging of CMakeJSON
set(CMakeJSON_DEBUG ON) # TODO: Remove this line later and turn off debugging by default!
set(CMakeJSON_DEBUG_PARSE ON)
set(CMakeJSON_DEBUG_RANGE_LOOP OFF)
set(CMakeJSON_DEBUG_HELPERS OFF)
set(CMakeJSON_DEBUG_RETURN_PARENT OFF)
set(CMakeJSON_DEBUG_PROJECT OFF)
set(CMakeJSON_DEBUG_PROJECT_OPTIONS OFF)
set(CMakeJSON_DEBUG_PROJECT_DEPENDENCIES OFF)
set(CMakeJSON_DEBUG_TARGET OFF)
###

project("SPWD.json")

feature_summary(WHAT ALL)