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




string(JSON length ERROR_VARIABLE err LENGTH "${json_contents}")
message(STATUS "Layout of JSON contents:'${sanitzed_layout}'")
message(STATUS "Length of JSON contents:'${length}'")
math(EXPR length "${length}-1")
foreach(json_index RANGE ${length})
    string(JSON member ERROR_VARIABLE err MEMBER "${json_contents}" ${json_index})
    if(err)
        cmake_print_variables(err)
    endif()
    string(JSON type ERROR_VARIABLE err TYPE "${json_contents}" ${member})
    if(err)
        cmake_print_variables(err)
    endif()
    list(FIND sanitzed_layout "project;${member}:${type}" found_index)
    if(found_index LESS 0)
        message(WARNING "Unknwon JSON member: project\;${member}:${type}")
    endif()
    string(JSON value ERROR_VARIABLE err GET "${json_contents}" ${member})
    if(err)
        cmake_print_variables(err)
    endif()

    message(STATUS "Member at index '${json_index}': '${member}':'${type}' = '${value}'")
endforeach()

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
    cmake_parse_arguments(PARSE_ARGV 0 "${_PREFIX}" "IS_ARRAY;IS_OBJECT" "JSON_INPUT" "CURRENT_JSON_MEMBER_BASE")
    if(${_PREFIX}_UNPARSED_ARGUMENTS)
    endif()

    set(access_list ${${_PREFIX}_ACCESS_LIST})
    string(JSON length ERROR_VARIABLE err LENGTH "${${_PREFIX}_INPUT_JSON}" ${_PREFIX}_CURRENT_JSON_MEMBER_BASE)
    math(EXPR length "${length}-1") # Correct range stop in for loop
    foreach(json_index RANGE ${length})
        set(member_or_index ${json_index})
        if(NOT _p_json_IS_ARRAY)
            string(JSON member ERROR_VARIABLE CMakeJSON_ParseError MEMBER "${${_PREFIX}_INPUT_JSON}" ${json_index})
            if(CMakeJSON_ParseError)
                cmake_print_variables(CMakeJSON_ParseError)
            endif()
            set(member_or_index ${member})
        endif()

        string(JSON type ERROR_VARIABLE CMakeJSON_ParseError TYPE "${${_PREFIX}_INPUT_JSON}" ${_PREFIX}_CURRENT_JSON_MEMBER_BASE ${member_or_index})

        if(type MATCHES "OBJECT|ARRAY")
            message(STATUS "Found ARRAY or OBJECT; Calling recursivly")
            cmakejson_parse_json(IS_${type} 
                                 JSON_INPUT 
                                    ${_PREFIX}_JSON_INPUT 
                                 CURRENT_JSON_MEMBER_BASE 
                                    ${_PREFIX}_CURRENT_JSON_MEMBER_BASE ${member_or_index})
        else() # STRING;NUMBER;BOOLEAN;NULL
            list(JOIN ${_PREFIX}_CURRENT_JSON_MEMBER_BASE ${member_or_index} "_" varname)
            set(_CMakeJSON_${varname} CHACHE INTERNAL "" )
        endif()

        if(CMakeJSON_ParseError)
            cmake_print_variables(CMakeJSON_ParseError)
        endif()
        if(type STREQUAL "ARRAY")
    endforeach()
endfunction()
