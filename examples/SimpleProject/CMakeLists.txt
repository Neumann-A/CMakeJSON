cmake_minimum_required(VERSION 3.19)

# Include CMakeJSON
# TODO: Decide wether to make this the default. 
set(CMakeJSON_ENABLE_PROJECT_OVERRIDE ON) # defines a macro called project() to silence a CMake Warning
set(CMakeJSON_DEBUG OFF) # TODO: Remove this line later and turn off debugging by default!
include("${CMAKE_CURRENT_SOURCE_DIR}/../../CMakeJSON/CMakeJSON.cmake")
project("Simple.Project.json")

feature_summary(WHAT ALL) # Purely optional.
