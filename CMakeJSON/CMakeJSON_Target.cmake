function(cmakejson_validate_target_json _jsoninput)
    list(APPEND CMAKE_MESSAGE_CONTEXT "validate")
    #TODO: Validate all fields in the input
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_gather_json_array_target_link_libraries_as_list _prefix _outvar)
    # Check for imported targets which package imported them via: IMPORTED_TARGETS
    # Make sure everything linked here is a target!
    set(element ${${_prefix}})
    if(NOT element AND DEFINED ${_prefix}_CONDITION)
        if(${${_prefix}_CONDITION} AND DEFINED ${_prefix}_LIBRARY)
            set(element ${${_prefix}_LIBRARY})
        elseif(${${_prefix}_CONDITION} AND DEFINED ${_prefix}_TARGET)
            set(element ${${_prefix}_TARGET})
        endif()
    endif()
    list(APPEND ${_outvar} ${element})
    set(${_outvar} ${${_outvar}} PARENT_SCOPE)
endfunction()

function(cmakejson_target_redirection)
endfunction()

function(cmakejson_add_public_header _prefix _target)
    set(element ${_prefix})
    set(value ${${element}})
    source_group(TREE ${CMAKE_CURRENT_LIST_DIR} FILES ${value})
    set_property(TARGET ${_target} APPEND PROPERTY PUBLIC_HEADER ${value})
    cmakejson_get_project_property(PROPERTY PUBLIC_HEADER_INSTALL_DESTINATION)
    get_filename_component(_int_path "${value}" DIRECTORY)
    if(NOT "${_int_path}" MATCHES "^${PUBLIC_HEADER_INSTALL_DESTINATION}$")
        get_filename_component(filename "${value}" NAME)
        get_filename_component(file "${value}" ABSOLUTE)
        set(includestring "#pragma once\n#include \"${CMAKE_CURRENT_SOURCE_DIR}/${value}\"\n\n")
        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${PUBLIC_HEADER_INSTALL_DESTINATION}/${filename}" "${includestring}")
    endif()
endfunction()

function(cmakejson_set_target_property _prefix _target)
    set_property(TARGET "${_target}" ${${_prefix}_APPEND_OPTION} PROPERTY "${${_prefix}_NAME}" "${${_prefix}_VALUE}")
endfunction()

function(cmakejson_add_target _input _filename)
    # Scope:
    # Add a unique target: <package-name>-<target-name> 
    # Reason: Avoid collisions if <target-name> is a common specifier
    # Exception: <package-name>==<target-name>
    # Create an alias target: <export-namespace>::<target-name> for consumption
    # Setup EXPORT_NAME as: <target-name> (so that exported target names are correct)
    # Setup library output name as: <package-name><target-name>
    # Setup everything else as expected (target_link_libraries etc.)
    # Setup BUILD_INTERFACE include dirs for public headers
    # Setup IDE target for INTERFACE targets (So that those are visible in IDEs like VS)
    # Export target by default.
    # Install target by default.

    list(APPEND CMAKE_MESSAGE_CONTEXT "target(${_filename})")

    cmakejson_validate_target_json("${_input}")

    list(APPEND CMAKE_MESSAGE_CONTEXT "parse")
    cmakejson_parse_json(JSON_INPUT "${_input}"
                         VARIABLE_PREFIX "TARGET"
                         OUTPUT_LIST_CREATED_VARIABLES "TARGET_PARSED_VARIABLES"
    )
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
    cmakejson_message_if(CMakeJSON_DEBUG_TARGET_VERBOSE "Variables created by target parse:")
    cmakejson_print_variables_if(CMakeJSON_DEBUG_TARGET_VERBOSE TARGET_PARSED_VARIABLES)

    if(DEFINED CMakeJSON_PARSE_TARGET_CONDITION AND NOT ${CMakeJSON_PARSE_TARGET_CONDITION})
        cmakejson_message_if(CMakeJSON_DEBUG_TARGET STATUS "Target condition '${CMakeJSON_PARSE_TARGET_CONDITION}' is false. Skipping target '${CMakeJSON_PARSE_TARGET_NAME}'!")
        list(POP_BACK CMAKE_MESSAGE_CONTEXT)
        return()
    endif()

    set(TARGET_LIB_PREFIX "")
    if(PARENT_PROJECT)
        cmakejson_get_parent_project_property(PROPERTY PACKAGE_NAME)
        set(TARGET_LIB_PREFIX "${PACKAGE_NAME}-")
        set(id_prefix "${PACKAGE_NAME}")
        cmakejson_get_project_property(PROPERTY PACKAGE_NAME)
    else()
        cmakejson_get_project_property(PROPERTY PACKAGE_NAME)
        if(NOT PACKAGE_NAME STREQUAL CMakeJSON_PARSE_TARGET_NAME)
            set(TARGET_LIB_PREFIX "${PACKAGE_NAME}-")
        endif()
        set(id_prefix "${PACKAGE_NAME}")
    endif()

    list(APPEND CMAKE_MESSAGE_CONTEXT "setup")
    if(NOT DEFINED CMakeJSON_PARSE_TARGET_NAME)
        set(CMakeJSON_PARSE_TARGET_NAME "${_filename}")
    else()
        cmake_language(EVAL CODE "set(CMakeJSON_PARSE_TARGET_NAME ${CMakeJSON_PARSE_TARGET_NAME})") # Evaluate variables stored in parsed variables.
    endif()
    if(NOT CMakeJSON_PARSE_TARGET_TARGET_TYPE MATCHES "library|executable|custom_target")
        message(${CMakeJSON_MSG_ERROR_TYPE} "Unknown value in member 'target_type' in target ${CMakeJSON_PARSE_TARGET_NAME}. Allowed values !")
    endif()

    set(target_command "add_${CMakeJSON_PARSE_TARGET_TARGET_TYPE}")
    unset(target_params)
    cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_TARGET_PARAMETERS cmakejson_gather_json_array_as_list target_params)

    unset(target_sources)
    cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_TARGET_SOURCES cmakejson_gather_json_array_as_list target_sources)

    set(target_name "${CMakeJSON_PARSE_TARGET_NAME}")
    set(raw_target_name "${target_name}")
    if(NOT id_prefix MATCHES ${target_name}$)
        # Only add the prefix if it does not MATCH the target name 
        set(target_name "${id_prefix}-${target_name}")
    endif()

    cmake_language(CALL ${target_command} ${target_name} ${target_params} ${target_sources})
    cmakejson_message_if(CMakeJSON_DEBUG_TARGET "Add target: ${target_command}(${target_name} ${target_params} ${target_sources})")
    # Setup CMakeJSON default settings early so they can be overwritten by the user
    set_property(TARGET ${target_name} PROPERTY EXPORT_NAME "${raw_target_name}")
    source_group(TREE "${CMAKE_CURRENT_LIST_DIR}" FILES ${target_sources})
    if(NOT PACKAGE_NAME STREQUAL "${target_name}" AND PACKAGE_NAME)
        set_property(TARGET ${target_name} PROPERTY OUTPUT_NAME ${TARGET_LIB_PREFIX}${CMakeJSON_PARSE_TARGET_NAME})
    endif()

    # Create alias target
    cmakejson_get_project_property(PROPERTY EXPORT_NAMESPACE)
    cmake_language(CALL ${target_command} ${EXPORT_NAMESPACE}::${CMakeJSON_PARSE_TARGET_NAME} ALIAS ${target_name})
    unset(EXPORT_NAMESPACE)

    # TODO: Make this detection fault prove.
    # Since 'target_params' is input this check is not 100% safe
    set(IS_OBJECT_LIBRARY FALSE)
    if(target_params MATCHES "OBJECT")
        set(IS_OBJECT_LIBRARY TRUE)
    endif()
    set(IS_INTERFACE_LIBRARY FALSE)
    set(TARGET_BUILD_INCLUDE_ACCESS "PUBLIC")
    if(target_params MATCHES "INTERFACE")
        set(IS_INTERFACE_LIBRARY TRUE)
        set(TARGET_BUILD_INCLUDE_ACCESS "INTERFACE")
    endif()

    # Setup target
    set(target_command_list 
                            compile_definitions
                            compile_features
                            compile_options
                            include_directories
                            link_directories
                            link_libraries
                            link_options
                            precompile_headers)
    
    foreach(_command IN LISTS target_command_list)
        string(TOUPPER "${_command}" parse_command)
        set(_command target_${_command})
        foreach(_access PUBLIC PRIVATE INTERFACE)
            unset(_params)
            cmakejson_message_if(CMakeJSON_DEBUG_TARGET_VERBOSE "Checking: CMakeJSON_PARSE_TARGET_${parse_command}_${_access}")
            if(COMMAND cmakejson_gather_json_array_${_command}_as_list)
                cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_TARGET_${parse_command}_${_access} cmakejson_gather_json_array_${_command}_as_list _params)
            else()
                cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_TARGET_${parse_command}_${_access} cmakejson_gather_json_array_as_list _params)
            endif()
            if(_params)
                cmake_language(EVAL CODE "set(_params ${_params})") # Evaluate variables stored in parsed variables.
                cmakejson_message_if(CMakeJSON_DEBUG_TARGET "Target command: ${_command}(${target_name} ${_access} ${_params})")
                cmake_language(CALL ${_command} ${target_name} ${_access} ${_params})
            endif()
            unset(_params)
        endforeach()
        unset(parse_command)
    endforeach()

    set(ide_sources ${target_sources})
    foreach(_command target_sources) # extra case for target_sources and add_dependencies
        string(TOUPPER "${_command}" parse_command)
        foreach(_access PUBLIC PRIVATE INTERFACE)
            set(_params)
            cmakejson_message_if(CMakeJSON_DEBUG_TARGET_VERBOSE "Checking: CMakeJSON_PARSE_TARGET_${parse_command}_${_access}")
            cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_TARGET_${parse_command}_${_access} cmakejson_gather_json_array_as_list _params)
            if(_params)
                cmake_language(EVAL CODE "set(_params ${_params})") # Evaluate variables stored in parsed variables.
                cmakejson_message_if(CMakeJSON_DEBUG_TARGET "Target command: ${_command}(${target_name} ${_access} ${_params})")
                cmake_language(CALL ${_command} ${target_name} ${_access} ${_params})
                if(_command STREQUAL "target_sources")
                    source_group(TREE ${CMAKE_CURRENT_LIST_DIR} FILES ${_params})
                    list(APPEND ide_sources ${_params})
                endif()
            endif()
            unset(_params)
        endforeach()
        unset(parse_command)
    endforeach()

    foreach(_command add_dependencies) # extra case for add_dependencies
        string(TOUPPER "${_command}" parse_command)
        set(_params)
        cmakejson_message_if(CMakeJSON_DEBUG_TARGET_VERBOSE "Checking: CMakeJSON_PARSE_TARGET_${parse_command}_${_access}")
        cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_TARGET_${parse_command}_${_access} cmakejson_gather_json_array_as_list _params)
        if(_params)
            cmake_language(EVAL CODE "set(_params ${_params})") # Evaluate variables stored in parsed variables.
            cmakejson_message_if(CMakeJSON_DEBUG_TARGET "Target command: ${_command}(${target_name} ${_access} ${_params})")
            cmake_language(CALL ${_command} ${target_name} ${_access} ${_params})
        endif()
        unset(_params)
        unset(parse_command)
    endforeach()

    cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_TARGET_PUBLIC_HEADERS cmakejson_add_public_header "${target_name}")
    target_include_directories("${target_name}" ${TARGET_BUILD_INCLUDE_ACCESS} "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>")

    cmakejson_get_project_property(PROPERTY PACKAGE_NAME)
    set_property(TARGET ${target_name} APPEND PROPERTY CMakeJSON_PACKAGE_NAME "${PACKAGE_NAME}")
    set_property(TARGET ${target_name} APPEND PROPERTY EXPORT_PROPERTIES CMakeJSON_PACKAGE_NAME)

    cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_TARGET_PROPERTIES cmakejson_set_target_property "${target_name}")

    list(POP_BACK CMAKE_MESSAGE_CONTEXT)

    if(IS_INTERFACE_LIBRARY AND NOT CMakeJSON_PARSE_TARGET_NO_IDE_INTERFACE_TARGET)
        # Create a target for INTERFACE targets so the sources are visible in an IDE
        add_custom_target(${target_name}_IDE DEPENDS ${target_name} SOURCES ${ide_sources})
    endif()

    if(NOT DEFINED CMakeJSON_PARSE_TARGET_EXPORT)
        set(CMakeJSON_PARSE_TARGET_EXPORT ON)
        if(CMakeJSON_PARSE_TARGET_TARGET_TYPE STREQUAL "custom_target")
            set(CMakeJSON_PARSE_TARGET_EXPORT OFF)
        elseif(IS_OBJECT_LIBRARY)
            set(CMakeJSON_PARSE_TARGET_EXPORT OFF)
        endif()
    endif()
    set(export_options)
    if(CMakeJSON_PARSE_TARGET_EXPORT)
        cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY EXPORTED_TARGETS ${target_name})
        cmakejson_get_project_property(PROPERTY EXPORT_NAME)
        set(export_options EXPORT "${EXPORT_NAME}")
    endif()

    if(NOT CMakeJSON_PARSE_TARGET_INSTALL_PARAMETERS)
        cmakejson_get_project_property(PROPERTY PUBLIC_HEADER_INSTALL_DESTINATION)
        # TODO: Make this better customizable from the json instead of overwriting everything.
        include(GNUInstallDirs)
        install(TARGETS ${target_name}
                ${export_options}
                RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT ${id_prefix}-Runtime
                LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT ${id_prefix}-Runtime NAMELINK_COMPONENT ${id_prefix}-Development 
                ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT ${id_prefix}-Development
                FRAMEWORK DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT ${id_prefix}-Development
                PUBLIC_HEADER DESTINATION "${PUBLIC_HEADER_INSTALL_DESTINATION}" COMPONENT ${id_prefix}-Development
                PRIVATE_HEADER DESTINATION "${PUBLIC_HEADER_INSTALL_DESTINATION}/private" COMPONENT ${id_prefix}-Development
        )
    else()
        cmake_language(EVAL CODE "set(_params ${CMakeJSON_PARSE_TARGET_INSTALL_PARAMETERS})") # Evaluate variables stored in parsed variables.
        install(TARGETS ${target_name}
                ${export_options}
                ${_params})
        unset(_params)
    endif()

    #TODO: Probably requires more special handling of public includes
    cmakejson_get_project_property(PROPERTY USAGE_INCLUDE_DIRECTORY)
    target_include_directories(${target_name} INTERFACE $<INSTALL_INTERFACE:${USAGE_INCLUDE_DIRECTORY}>)
    if(DEFINED CMakeJSON_PARSE_TARGET_PUBLIC_INCLUDE_DIRECTORY)
        install(DIRECTORY ${CMakeJSON_PARSE_TARGET_PUBLIC_INCLUDE_DIRECTORY} DESTINATION ${USAGE_INCLUDE_DIRECTORY} COMPONENT ${id_prefix}-Development)
    endif()

    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_target_file _file)
    file(TO_CMAKE_PATH "${_file}" _file)
    get_filename_component(file "${_file}" ABSOLUTE)
    if(NOT EXISTS "${file}")
        message(FATAL_ERROR "File '${_file}' does not exists!")
    endif()
    message(${CMakeJSON_MSG_VERBOSE_TYPE} "Reading target JSON: '${_file}'")
    get_filename_component(_filename "${_file}" NAME_WE)
    file(READ "${file}" _contents)
    cmakejson_add_target("${_contents}" "${_filename}")
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${file}")
endfunction()
