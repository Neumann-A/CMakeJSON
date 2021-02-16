# Should use external projects here. 
option(CMakeJSON_EXAMPLES "Include the examples in the configure call" ON)
if(CMakeJSON_EXAMPLES)
    add_subdirectory(SimpleProjectTest) # Internal testing & debugging example
    #add_subdirectory(SimpleProject) # Real example
endif()