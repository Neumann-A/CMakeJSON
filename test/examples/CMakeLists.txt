# This file is for testing the generated CMake configs. 
include(ExternalProject)
#set(CMAKE_DISABLE_IN_SOURCE_BUILD OFF CACHE INTERNAL "Disable building in source directory." FORCE) # undocumented
set(CMAKE_DISABLE_SOURCE_CHANGES OFF CACHE INTERNAL "Disable changes to sources" FORCE) # undocumented

ExternalProject_Add(SimpleProject_test  SOURCE_DIR "${CMAKE_SOURCE_DIR}/examples/SimpleProject"
                                        PREFIX "${CMAKE_BINARY_DIR}/install_test"
                                        STEP_TARGETS build install
                                        BUILD_ALWAYS TRUE
                                        )

ExternalProject_Add(SimpleProjectWithDep_test   SOURCE_DIR "${CMAKE_SOURCE_DIR}/examples/SimpleProjectWithDep"
                                                PREFIX "${CMAKE_BINARY_DIR}/install_test"
                                                DEPENDS SimpleProject_test-install # not really just to chain the projects
                                                #CMAKE_GENERATOR "Ninja"
                                                CMAKE_CACHE_ARGS   "-DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_BINARY_DIR}/install_test"
                                                                   "-DCMAKE_PREFIX_PATH:STRING=${CMAKE_BINARY_DIR}/install_test"
                                                STEP_TARGETS install
                                                BUILD_ALWAYS )

ExternalProject_Add(ProjectWithComponents_test  SOURCE_DIR "${CMAKE_SOURCE_DIR}/examples/ProjectWithComponents"
                                                PREFIX "${CMAKE_BINARY_DIR}/install_test"
                                                DEPENDS SimpleProjectWithDep_test-install # not really just to chain the projects
                                                CMAKE_CACHE_ARGS    "-DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_BINARY_DIR}/install_test"
                                                                    "-DCMAKE_PREFIX_PATH:STRING=${CMAKE_BINARY_DIR}/install_test"
                                                STEP_TARGETS install
                                                BUILD_ALWAYS )

ExternalProject_Add(TestWithComponents_test     SOURCE_DIR "${CMAKE_SOURCE_DIR}/examples/ProjectWithComponents"
                                                PREFIX "${CMAKE_BINARY_DIR}/install_test"
                                                DEPENDS ProjectWithComponents_test-install
                                                CMAKE_CACHE_ARGS    "-DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_BINARY_DIR}/install_test"
                                                                    "-DCMAKE_PREFIX_PATH:STRING=${CMAKE_BINARY_DIR}/install_test"
                                                STEP_TARGETS install
                                                BUILD_ALWAYS )