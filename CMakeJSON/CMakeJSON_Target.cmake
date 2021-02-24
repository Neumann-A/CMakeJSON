function(cmakejson_validate_target_json _jsoninput)
    list(APPEND CMAKE_MESSAGE_CONTEXT "validate")
    #TODO: Validate all fields in the input
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_gather_json_array_as_list _prefix _outvar)
    set(element ${${_prefix}})
    list(APPEND ${_outvar} ${element})
    set(${_outvar} ${${_outvar}} PARENT_SCOPE)
endfunction()

function(cmakejson_target_redirection)
endfunction()

function(cmakejson_add_target _input _filename)
    list(APPEND CMAKE_MESSAGE_CONTEXT "target")

    cmakejson_validate_target_json("${_input}")

    list(APPEND CMAKE_MESSAGE_CONTEXT "parse")
    cmakejson_parse_json(JSON_INPUT "${_input}"
                         VARIABLE_PREFIX "TARGET"
                         OUTPUT_LIST_CREATED_VARIABLES "TARGET_PARSED_VARIABLES"
    )
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
    cmakejson_message_if(CMakeJSON_DEBUG_TARGET STATUS "Variables created by target parse:")
    cmakejson_print_variables_if(CMakeJSON_DEBUG_TARGET TARGET_PARSED_VARIABLES)

    if(NOT DEFINED CMakeJSON_PARSE_TARGET_NAME)
        set(CMakeJSON_PARSE_TARGET_NAME "${_filename}")
    endif()
    if(NOT CMakeJSON_PARSE_TARGET_TARGET_TYPE MATCHES "library|executable|custom_target")
        message(${CMakeJSON_MSG_ERROR_TYPE} "Unknown value in member 'target_type' in target ${CMakeJSON_PARSE_TARGET_NAME}. Allowed values !")
    endif()
    set(target_command "add_${CMakeJSON_PARSE_TARGET_TARGET_TYPE}")
    set(target_params)
    cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_TARGET_PARAMETERS cmakejson_gather_json_array_as_list target_params)

    set(target_sources)
    cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_TARGET_SOURCES cmakejson_gather_json_array_as_list target_sources)

    set(target_name ${CMakeJSON_PARSE_TARGET_NAME})
    cmake_language(CALL ${target_command} ${target_name} ${target_params} ${target_sources})
    cmakejson_message_if(CMakeJSON_DEBUG_TARGET "Add target: ${target_command}(${target_name} ${target_params} ${target_sources})")

    set(target_command_list include_directories
                            compile_definitions
                            compile_options
                            compile_features
                            link_libraries)
    
    foreach(_command IN LISTS target_command_list)
        string(TOUPPER "${_command}" parse_command)
        set(_command target_${_command})
        foreach(_access PUBLIC PRIVATE INTERFACE)
            set(_params)
            cmakejson_message_if(CMakeJSON_DEBUG_TARGET "Checking: CMakeJSON_PARSE_TARGET_${parse_command}_${_access}")
            cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_TARGET_${parse_command}_${_access} cmakejson_gather_json_array_as_list _params)
            if(_params)
                cmake_language(EVAL CODE "set(_params ${_params})") # Evaluate variables stored in parsed variables.
                #list(LENGTH _params _length)
                #message(STATUS "LENGTH:${_length}") 
                #if(_length GREATER 1)
                #    list(GET _params 1 _elem)
                #    message(STATUS "ELEMENT:${_elem}") 
                #endif()
                cmakejson_message_if(CMakeJSON_DEBUG_TARGET "Target command: ${_command}(${target_name} ${_access} ${_params})")
                cmake_language(CALL ${_command} ${target_name} ${_access} ${_params})
            endif()
            unset(_params)
        endforeach()
        unset(parse_command)
    endforeach()

    # TODO Some extra CMakeJSON setup

    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_target_file _file)
    file(TO_CMAKE_PATH "${_file}" _file)
    if(IS_ABSOLUTE "${_file}")
        set(file "${_file}")
    else()
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_file}")
            set(file "${CMAKE_CURRENT_SOURCE_DIR}/${_file}")
        else()
            message(FATAL_ERROR "File '${_file}' does not exists!\nNeither is it absolute nor does it exists in the directory '${CMAKE_CURRENT_SOURCE_DIR}'!")
        endif()
    endif()
    get_filename_component(_filename "${_file}" NAME_WE)
    file(READ "${_file}" _contents)
    cmakejson_add_target("${_contents}" "${_filename}")
endfunction()
