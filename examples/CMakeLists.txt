# Should use external projects here. 
option(CMakeJSON_EXAMPLES "Include the examples in the configure call" ON)
if(CMakeJSON_EXAMPLES)
    add_subdirectory(SimpleProject)
    add_subdirectory(SimpleProjectWithDep) #TODO
    add_subdirectory(ProjectWithComponents)
endif()