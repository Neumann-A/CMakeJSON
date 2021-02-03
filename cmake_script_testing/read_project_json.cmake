include(CMakePrintHelpers)
file(READ "${CMAKE_CURRENT_LIST_DIR}/project_json_testing.json" json_contents)

set(CMakeJSON_LAYOUT_REGEX [=[^([a-z]*;)*[a-z]*:(NUMBER|STRING((:[a-zA-Z0-9]+)(\|[[a-zA-Z0-9]+))?|BOOLEAN|ARRAY|OBJECT)(;OPTIONAL)?]=])
file(STRINGS "${CMAKE_CURRENT_LIST_DIR}/../CMakeJSON/layouts/project_layout.txt" layout_contents 
             REGEX "${CMakeJSON_LAYOUT_REGEX}")

set(sanitzed_layout)
foreach(line IN LISTS layout_contents)
    string(REGEX REPLACE " +#.*" "" line "${line}")
    string(STRIP "${line}" line)
    string(FIND "${line}" ":" splitpos)
    string(SUBSTRING "${line}" 0 ${splitpos} variable_name)
    math(EXPR splitpos "${splitpos}+1")
    string(SUBSTRING "${line}" ${splitpos} -1  info)
    string(REGEX REPLACE [[;]] "_" variable_name "${variable_name}")
    string(PREPEND variable_name "CMakeJSON_layout_")

    list(GET info 0 type_info)
    if(type_info MATCHES ":")
        string(FIND "${type}" ":" splitpos)
        string(SUBSTRING "${type}" 0 ${splitpos} type)
        math(EXPR splitpos "${splitpos}+1")
        string(SUBSTRING "${line}" ${splitpos} -1  allowed_regex)
    else()
        set(type ${type_info})
    endif()

    math(EXPR splitpos "${splitpos}+1")
    list(LENGTH info infolength)
    if(infolength GREATER 1)
        list(SUBLIST info 1 -1 addinfo)
        list(FIND addinfo "OPTIONAL" optional_index)
        if(NOT optional_index EQUAL -1)
            message(STATUS "Setting: ${variable_name} to optional!")
            set(${variable_name}_IS_OPTIONAL TRUE)
        endif()
    endif()

    set(${variable_name}_INFO )
    string(REGEX REPLACE [[;]] "\\\;" line "${line}")
    message(STATUS "${variable_name} : '${type}' : '${addinfo}'")

    list(APPEND sanitzed_layout "${line}")
endforeach()

# string(JSON length ERROR_VARIABLE err LENGTH "${json_contents}")
# message(STATUS "Layout of JSON contents:'${sanitzed_layout}'")
# message(STATUS "Length of JSON contents:'${length}'")
# math(EXPR length "${length}-1")
# foreach(json_index RANGE ${length})
#     string(JSON member ERROR_VARIABLE err MEMBER "${json_contents}" ${json_index})
#     if(err)
#         cmake_print_variables(err)
#     endif()
#     string(JSON type ERROR_VARIABLE err TYPE "${json_contents}" ${member})
#     if(err)
#         cmake_print_variables(err)
#     endif()
#     list(FIND sanitzed_layout "project;${member}:${type}" found_index)
#     if(found_index LESS 0)
#         message(WARNING "Unknwon JSON member: project\;${member}:${type}")
#     endif()
#     string(JSON value ERROR_VARIABLE err GET "${json_contents}" ${member})
#     if(err)
#         cmake_print_variables(err)
#     endif()

#     message(STATUS "Member at index '${json_index}': '${member}':'${type}' = '${value}'")
# endforeach()

# Macro to create a unique prefix for cmake_parse_arguments within a function
macro(cmakejson_create_function_parse_arguments_prefix)
    string(REGEX REPLACE  "_([a-zA-Z])[^_]+" "\\1" ${ARGV0} "${CMAKE_CURRENT_FUNCTION}")
    string(REPLACE "cmakejson" "_cmakejson_" ${ARGV0} "${${ARGV0}}")
endmacro()

# Macro to return ARGN variables from the currently scoped function into the calling function
macro(cmakejson_return_variables)
    foreach(arg IN ITEMS ${ARGN})
        set(${arg} ${${arg}} PARENT_SCOPE)
    endforeach()
endmacro()

# Function to parse json files
# This function will be called recursivley until all members have been discovered and the values been set to 
function(cmakejson_parse_json)
    cmakejson_create_function_parse_arguments_prefix(_PREFIX)
    cmake_parse_arguments(PARSE_ARGV 0 "${_PREFIX}" "IS_ARRAY;IS_OBJECT" "JSON_INPUT;VARIABLE_PREFIX" "CURRENT_JSON_MEMBER_BASE")
    if(${_PREFIX}_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} at ${CMAKE_CURRENT_FUNCTION_LIST_LINE}: Unknown parameters passed. UNPARSED:'${${_PREFIX}_UNPARSED_ARGUMENTS}' ")
    endif()

    ### Setting up helper variables. 
    list(TRANSFORM ${_PREFIX}_CURRENT_JSON_MEMBER_BASE TOUPPER OUTPUT_VARIABLE JSON_MEMBER_BASE_VAR)
    list(JOIN JSON_MEMBER_BASE_VAR "_" JSON_MEMBER_BASE_VAR)
    set(CMakeJSON_CURRENT_VAR_PREFIX)
    if(${_PREFIX}_VARIABLE_PREFIX AND JSON_MEMBER_BASE_VAR)
        set(CMakeJSON_CURRENT_VAR_PREFIX ${${_PREFIX}_VARIABLE_PREFIX}_${JSON_MEMBER_BASE_VAR})
    elseif(${_PREFIX}_VARIABLE_PREFIX)
        set(CMakeJSON_CURRENT_VAR_PREFIX ${${_PREFIX}_VARIABLE_PREFIX})
    elseif(JSON_MEMBER_BASE_VAR)
        set(CMakeJSON_CURRENT_VAR_PREFIX ${JSON_MEMBER_BASE_VAR})
    endif()
    cmake_print_variables(CMakeJSON_CURRENT_VAR_PREFIX)

    ### Parsing logic
    set(access_list ${${_PREFIX}_ACCESS_LIST})
    string(JSON length ERROR_VARIABLE err LENGTH "${${_PREFIX}_JSON_INPUT}" ${${_PREFIX}_CURRENT_JSON_MEMBER_BASE})
    if(NOT length)
        message(FATAL_ERROR "No length in '${${_PREFIX}_CURRENT_JSON_MEMBER_BASE}'")
    endif()
    math(EXPR range_length "${length}-1") # Correct range stop in for loop
    foreach(json_index RANGE ${range_length})
        set(member_or_index ${json_index})
        if(NOT ${_PREFIX}_IS_ARRAY)
            string(JSON member ERROR_VARIABLE CMakeJSON_ParseError MEMBER "${${_PREFIX}_JSON_INPUT}" ${json_index})
            if(CMakeJSON_ParseError)
                cmake_print_variables(CMakeJSON_ParseError)
            endif()
            set(member_or_index ${member})
        else()
            set(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX} ${length} CACHE INTERNAL "" )
        endif()

        string(JSON type ERROR_VARIABLE CMakeJSON_ParseError TYPE "${${_PREFIX}_JSON_INPUT}" ${${_PREFIX}_CURRENT_JSON_MEMBER_BASE} ${member_or_index})
        string(JSON contents ERROR_VARIABLE CMakeJSON_ParseError GET "${${_PREFIX}_JSON_INPUT}" ${${_PREFIX}_CURRENT_JSON_MEMBER_BASE} ${member_or_index})
        #cmake_print_variables(member_or_index)
        #cmake_print_variables(contents)
        if(type MATCHES "OBJECT|ARRAY")
            message(STATUS "Found ARRAY or OBJECT (${type}); Calling recursivly")
            if(type STREQUAL OBJECT)
                string(TOUPPER "${member_or_index}" object_name)
                cmakejson_parse_json(IS_${type} 
                                    JSON_INPUT 
                                        "${contents}"
                                    VARIABLE_PREFIX
                                        ${CMakeJSON_CURRENT_VAR_PREFIX}_${object_name}
                                    )
            else()
                string(TOUPPER "${member_or_index}" array_name)
                cmakejson_parse_json(IS_${type} 
                                     JSON_INPUT 
                                        "${contents}"
                                     VARIABLE_PREFIX
                                        ${CMakeJSON_CURRENT_VAR_PREFIX}_${array_name}
                                    )
                cmake_print_variables(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${array_name})
            endif()
        else() # STRING;NUMBER;BOOLEAN;NULL
            #cmake_print_variables(${_PREFIX}_IS_ARRAY)
            #cmake_print_variables(${_PREFIX}_IS_OBJECT)
            if(${_PREFIX}_IS_ARRAY)
                set(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${json_index} ${contents} CACHE INTERNAL "" )
                cmake_print_variables(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${json_index})
            elseif(${_PREFIX}_IS_OBJECT)
                string(TOUPPER "${member_or_index}" object_name)
                set(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${object_name} ${contents} CACHE INTERNAL "" )
                cmake_print_variables(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${object_name})
            else()
                set(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX} ${contents} CACHE INTERNAL "" )
                cmake_print_variables(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX})
            endif()
        endif()

        if(CMakeJSON_ParseError)
            cmake_print_variables(CMakeJSON_ParseError)
        endif()

    endforeach()
endfunction()

function(cmakejson_create_project)
    set(PROJECT_PARAMS "${CMakeJSON_PARSE_PROJECT_NAME}")
    if(CMakeJSON_PARSE_PROJECT_VERSION)
        list(APPEND PROJECT_PARAMS VERSION "${CMakeJSON_PARSE_PROJECT_VERSION}")
    endif()
    if(CMakeJSON_PARSE_PROJECT_DESCRIPTION)
        list(APPEND PROJECT_PARAMS DESCRIPTION "${CMakeJSON_PARSE_PROJECT_DESCRIPTION}")
    endif()
    if(CMakeJSON_PARSE_PROJECT_HOMEPAGE)
        list(APPEND PROJECT_PARAMS HOMEPAGE_URL "${CMakeJSON_PARSE_PROJECT_HOMEPAGE}")
    endif()
    if(CMakeJSON_PARSE_PROJECT_HOMEPAGE)
        list(APPEND PROJECT_PARAMS LANGUAGES "${CMakeJSON_PARSE_PROJECT_LANGUAGES}")
    endif()
    _project(${PROJECT_PARAMS})
endfunction()


### Loading Stuff
message(STATUS "############################ Validate JSON ##########################")
message(STATUS "############################## Parse JSON ###########################")
cmakejson_parse_json(IS_OBJECT JSON_INPUT "${json_contents}" VARIABLE_PREFIX "PROJECT")
message(STATUS "############################ Create Project #########################")
cmakejson_create_project_options()
cmakejson_create_project()
cmakejson_resolve_project_dependencies()
