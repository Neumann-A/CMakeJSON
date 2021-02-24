# Function to parse json files
# This function will be called recursivley until all members have been discovered and the values been set to 
function(cmakejson_parse_json)
    cmakejson_create_function_parse_arguments_prefix(_PREFIX)
    cmake_parse_arguments(PARSE_ARGV 0 "${_PREFIX}" "IS_ARRAY;IS_OBJECT" "JSON_INPUT;VARIABLE_PREFIX;OUTPUT_LIST_CREATED_VARIABLES" "CURRENT_JSON_MEMBER_BASE")
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
    cmakejson_print_variables_if(CMakeJSON_DEBUG_PARSE CMakeJSON_CURRENT_VAR_PREFIX)

    ### Parsing logic
    set(access_list ${${_PREFIX}_ACCESS_LIST})
    string(JSON length ERROR_VARIABLE err LENGTH "${${_PREFIX}_JSON_INPUT}" ${${_PREFIX}_CURRENT_JSON_MEMBER_BASE})
    if(NOT length)
        message(FATAL_ERROR "No length in '${${_PREFIX}_CURRENT_JSON_MEMBER_BASE}'")
    endif()
    math(EXPR range_length "${length}-1") # Correct range stop in for loop
    if(${_PREFIX}_IS_ARRAY)
        set(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_LENGTH ${length})
        list(APPEND ${${_PREFIX}_OUTPUT_LIST_CREATED_VARIABLES} CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_LENGTH)
        cmakejson_print_variables_if(CMakeJSON_DEBUG_PARSE CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_LENGTH)
    endif()
    foreach(json_index RANGE ${range_length})
        set(member_or_index ${json_index})
        if(NOT ${_PREFIX}_IS_ARRAY)
            string(JSON member ERROR_VARIABLE CMakeJSON_ParseError MEMBER "${${_PREFIX}_JSON_INPUT}" ${json_index})
            if(CMakeJSON_ParseError)
                cmakejson_print_variables_if(CMakeJSON_DEBUG_PARSE CMakeJSON_ParseError)
            endif()
            set(member_or_index ${member})
        endif()

        string(JSON type ERROR_VARIABLE CMakeJSON_ParseError TYPE "${${_PREFIX}_JSON_INPUT}" ${${_PREFIX}_CURRENT_JSON_MEMBER_BASE} ${member_or_index})
        string(JSON contents ERROR_VARIABLE CMakeJSON_ParseError GET "${${_PREFIX}_JSON_INPUT}" ${${_PREFIX}_CURRENT_JSON_MEMBER_BASE} ${member_or_index})
        #cmake_print_variables(member_or_index)
        #cmake_print_variables(contents)
        if(type MATCHES "OBJECT|ARRAY")
            cmakejson_message_if(CMakeJSON_DEBUG_PARSE STATUS "Found ARRAY or OBJECT (${type}); Calling recursivly")
            if(type STREQUAL OBJECT)
                string(TOUPPER "${member_or_index}" member_name)
                cmakejson_parse_json(IS_${type} 
                                    JSON_INPUT 
                                        "${contents}"
                                    VARIABLE_PREFIX
                                        ${CMakeJSON_CURRENT_VAR_PREFIX}_${member_name}
                                    OUTPUT_LIST_CREATED_VARIABLES
                                        ${${_PREFIX}_OUTPUT_LIST_CREATED_VARIABLES}
                                    )
            else()
                string(TOUPPER "${member_or_index}" member_name)
                cmakejson_parse_json(IS_${type} 
                                     JSON_INPUT 
                                        "${contents}"
                                     VARIABLE_PREFIX
                                        ${CMakeJSON_CURRENT_VAR_PREFIX}_${member_name}
                                     OUTPUT_LIST_CREATED_VARIABLES
                                        ${${_PREFIX}_OUTPUT_LIST_CREATED_VARIABLES}
                                    )
            endif()
        else() # STRING;NUMBER;BOOLEAN;NULL
            if(${_PREFIX}_IS_ARRAY)
                #set(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${json_index} ${contents} CACHE INTERNAL "" )
                list(APPEND ${${_PREFIX}_OUTPUT_LIST_CREATED_VARIABLES} CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${json_index})
                set(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${json_index} ${contents})
                cmakejson_print_variables_if(CMakeJSON_DEBUG_PARSE CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${json_index})
            elseif(${_PREFIX}_IS_OBJECT)
                string(TOUPPER "${member_or_index}" object_name)
                #set(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${object_name} ${contents} CACHE INTERNAL "" )
                list(APPEND ${${_PREFIX}_OUTPUT_LIST_CREATED_VARIABLES} CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${object_name})
                set(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${object_name} ${contents})
                cmakejson_print_variables_if(CMakeJSON_DEBUG_PARSE CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${object_name})
            else()
                #set(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX} ${contents} CACHE INTERNAL "" )
                string(TOUPPER "${member_or_index}" field_name)
                list(APPEND ${${_PREFIX}_OUTPUT_LIST_CREATED_VARIABLES} CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${field_name})
                set(CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${field_name} ${contents})
                cmakejson_print_variables_if(CMakeJSON_DEBUG_PARSE CMakeJSON_PARSE_${CMakeJSON_CURRENT_VAR_PREFIX}_${field_name})
            endif()
        endif()

        cmakejson_print_variables_if(CMakeJSON_DEBUG_PARSE ${${_PREFIX}_OUTPUT_LIST_CREATED_VARIABLES})

        if(CMakeJSON_ParseError)
            cmakejson_print_variables_if(CMakeJSON_DEBUG_PARSE CMakeJSON_ParseError)
        endif()
        #list(APPEND ${${${_PREFIX}_OUTPUT_LIST_CREATED_VARIABLES}} ${${_PREFIX}_OUTPUT_LIST_CREATED_VARIABLES})
    endforeach()
    # Return output variables to parent scope
    cmakejson_return_to_parent_scope(${${_PREFIX}_OUTPUT_LIST_CREATED_VARIABLES} ${${${_PREFIX}_OUTPUT_LIST_CREATED_VARIABLES}})
endfunction()

function(cmakejson_run_func_over_parsed_range _varprefix _function)
    #list(APPEND CMAKE_MESSAGE_CONTEXT "range_foreach")
    if(DEFINED ${_varprefix}_LENGTH AND ${_varprefix}_LENGTH GREATER_EQUAL 1)
        get_directory_property(vars_before VARIABLES)
        math(EXPR cmakejson_run_func_over_parsed_range "${${_varprefix}_LENGTH}-1")
        foreach(cmakejson_run_func_over_parsed_range_index RANGE 0 ${cmakejson_run_func_over_parsed_range})
            cmakejson_message_if(CMakeJSON_DEBUG_RANGE_LOOP "Index: ${cmakejson_run_func_over_parsed_range_index}/${cmakejson_run_func_over_parsed_range}")
            cmakejson_message_if(CMakeJSON_DEBUG_RANGE_LOOP "Command: ${_function}(${_varprefix}_${cmakejson_run_func_over_parsed_range_index} ${ARGN})")
            cmake_language(CALL ${_function} "${_varprefix}_${cmakejson_run_func_over_parsed_range_index}" ${ARGN})
        endforeach()
        get_directory_property(vars_after VARIABLES)
        list(REMOVE_ITEM vars_after ${vars_before})
        cmakejson_return_to_parent_scope(${vars_after})
        unset(cmakejson_run_func_over_parsed_range)
        unset(cmakejson_run_func_over_parsed_range_index)
    endif()
    #list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()
