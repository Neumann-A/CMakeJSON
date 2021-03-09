# Most of the functions in here are macros since the findModule defines its own scipe any way!
function(cmakejson_validate_find_module_json _input)
    list(APPEND CMAKE_MESSAGE_CONTEXT "validate")
    #TODO: Validate all fields in the input
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_gather_json_array_configuration_as_list _prefix _outvar)
    set(element ${${_prefix}_CONFIG})
    cmakejson_run_func_over_parsed_range(${_prefix}_LIB_PREFIXES cmakejson_gather_json_array_as_list _prefixes)
    cmakejson_run_func_over_parsed_range(${_prefix}_LIB_SUFFIXES cmakejson_gather_json_array_as_list _suffixes)
    set(CMakeJSON_MODULE_${element}_LIB_PREFIXES "${_prefixes}" PARENT_SCOPE)
    set(CMakeJSON_MODULE_${element}_LIB_SUFFIXES "${_suffixes}" PARENT_SCOPE)
    list(APPEND ${_outvar} ${element})
    set(${_outvar} ${${_outvar}} PARENT_SCOPE)
endfunction()

function(cmakejson_create_imported_targets _prefix _found_vars)
    
    set(_target ${CMAKE_FIND_PACKAGE_NAME}::${${_prefix}_NAME}))
    if(NOT TARGET ${_target})
        set(_mod_found_name ${CMAKE_FIND_PACKAGE_NAME}_TARGET_${${_prefix}_NAME}_FOUND)
        set(${_mod_found_name} FALSE PARENT_SCOPE)
        list(APPEND ${_found_vars} ${_mod_found_name})
        set(${_found_vars} ${${_found_vars}} PARENT_SCOPE)

        set(_type UNKNOWN)
        if(NOT DEFINED ${_prefix}_LIBRARY_NAMES)
            set(_type INTERFACE)
        endif()
        add_library(${_target} ${_type} IMPORTED)
        cmakejson_run_func_over_parsed_range(${_prefix}_LIBRARY_NAMES cmakejson_gather_json_array_as_list _lib_names)
        foreach(_config IN LISTS CMakeJSON_MODULE_CONFIGURATIONS)
            set(additional_lib_names)
            foreach(_lib_prefix IN LISTS CMakeJSON_MODULE_${_config}_LIB_PREFIXES)
                set(_tmp_lib_names "${_lib_names}")
                list(TRANSFORM _tmp_lib_names PREPEND "${_lib_prefix}")
                list(APPEND additional_lib_names ${_tmp_lib_names})
                foreach(_lib_suffix IN LISTS CMakeJSON_MODULE_${_config}_LIB_SUFFIXES)
                    list(TRANSFORM _tmp_lib_names APPEND "${_lib_suffix}")
                    list(APPEND additional_lib_names ${_lib_name}) 
                endforeach()
            endforeach()
            foreach(_lib_suffix IN LISTS CMakeJSON_MODULE_${_config}_LIB_SUFFIXES)
                set(_tmp_lib_names "${_lib_names}")
                list(TRANSFORM _tmp_lib_names PREPEND "${_lib_suffix}")
                list(APPEND additional_lib_names ${_tmp_lib_names})
                foreach(_lib_prefix IN LISTS CMakeJSON_MODULE_${_config}_LIB_PREFIXES)
                    list(TRANSFORM _tmp_lib_names APPEND "${_lib_prefix}")
                    list(APPEND additional_lib_names ${_lib_name}) 
                endforeach()
            endforeach()
            if(_config STREQUAL "DEBUG")
                find_library(${CMAKE_FIND_PACKAGE_NAME}_${${_prefix}_NAME}_LIBRARY_${_config} NAMES ${_lib_names} ${additional_lib_names} NAMES_PER_DIR ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
            elseif(_config STREQUAL "RELEASE")
                find_library(${CMAKE_FIND_PACKAGE_NAME}_${${_prefix}_NAME}_LIBRARY_${_config} NAMES ${_lib_names} ${additional_lib_names} NAMES_PER_DIR ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
            endif()
            find_library(${CMAKE_FIND_PACKAGE_NAME}_${${_prefix}_NAME}_LIBRARY_${_config} NAMES ${_lib_names} ${additional_lib_names} NAMES_PER_DIR)
            if(${CMAKE_FIND_PACKAGE_NAME}_${${_prefix}_NAME}_LIBRARY_${_config})
                set_target_properties(${_target} PROPERTIES
                                                    IMPORTED_LOCATION_${_config}
                                                    ${${CMAKE_FIND_PACKAGE_NAME}_${${_prefix}_NAME}_LIBRARY_${_config}})
                                                    IMPORTED_LINK_INTERFACE_LANGUAGES
                                                    ${CMakeJSON_MODULE_LANGUAGES}
                                                    )
                set(${_mod_found_name} TRUE PARENT_SCOPE)
            endif()
        endforeach()
        cmakejson_run_func_over_parsed_range(${_prefix}_HEADER_FILE cmakejson_gather_json_array_as_list _header)
        find_file(_cmakejson_header_path NAMES ${_header} PATH_SUFFIXES "include")
        if(_cmakejson_module_header_path)
            get_filename_component(${CMAKE_FIND_PACKAGE_NAME}_${${_prefix}_NAME}_INCLUDE_DIR "${_cmakejson_module_header_path}" DIRECTORY CACHE)
        endif()
        unset(_cmakejson_module_header_path CACHE)
        if(${CMAKE_FIND_PACKAGE_NAME}_${${_prefix}_NAME}_INCLUDE_DIR)
        target_include_directories(${_target} INTERFACE ${${CMAKE_FIND_PACKAGE_NAME}_${${_prefix}_NAME}_INCLUDE_DIR})
        endif()
        cmakejson_run_func_over_parsed_range(${_prefix}_LINK_LIBRARIES cmakejson_gather_json_array_as_list _link_libs)
        if(_link_libs)
            target_link_libraries(${_target} INTERFACE ${_link_libs})
        endif()
        cmakejson_run_func_over_parsed_range(${_prefix}_INCLUDE_DIRECTORIES cmakejson_gather_json_array_as_list _includes)
        if(_includes)
            target_include_directories(${_target} INTERFACE ${_includes})
        endif()
    endif()
endfunction(cmakejson_create_imported_targets)

function(cmakejson_check_config_targets_vs_imported_targets)
    #TODO
endfunction()

macro(cmakejson_find_package_config)
    list(APPEND CMAKE_MESSAGE_CONTEXT "conifg_search")
    if(NOT DEFINED CMakeJSON_PARSE_MODULE_CONFIG_NAME)
        set(CMakeJSON_PARSE_MODULE_CONFIG_NAME "${CMAKE_FIND_PACKAGE_NAME}")
    endif()
    if(DEFINED ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
        list(APPEND config_find_str COMPONENTS "${${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS}")
    endif()
    find_package(${CMakeJSON_PARSE_MODULE_CONFIG_NAME})
    if(${CMakeJSON_PARSE_MODULE_CONFIG_NAME}_FOUND)
        #TODO check expected imported targets!
        #TODO check config_name
        find_package_handle_standard_args(${CMAKE_FIND_PACKAGE_NAME} 
                                          HANDLE_VERSION_RANGE 
                                          HANDLE_COMPONENTS
                                          CONFIG_MODE
                                         )
    endif()
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endmacro()

function(cmakejson_redirect_imported_targets_to_pkgconfig_target _prefix _pkgconfigtarget)
    set(_target ${CMAKE_FIND_PACKAGE_NAME}::${${_prefix}_NAME}))
    if(NOT TARGET ${_target})
        add_library(${_target} INTERFACE IMPORTED)
        target_link_libraries(${_target} INTERFACE ${_pkgconfigtarget})
    endif()
endfunction()

macro(cmakejson_find_package_pkgconfig)
    list(APPEND CMAKE_MESSAGE_CONTEXT "pkgconfig_search")
    if(NOT DEFINED CMakeJSON_PARSE_MODULE_PKG_CONFIG_NAME)
        string(TOLOWER "${CMAKE_FIND_PACKAGE_NAME}" CMakeJSON_PARSE_MODULE_PKG_CONFIG_NAME)
    endif()
    #TODO add pkg specs
    set(_versionstr)
    if(PACKAGE_FIND_VERSION_MIN)
        set(_versionstr ">=${PACKAGE_FIND_VERSION_MIN}")
    endif()
    pkg_check_modules(${CMAKE_FIND_PACKAGE_NAME}_PC IMPORTED_TARGET "${CMakeJSON_PARSE_MODULE_PKG_CONFIG_NAME}${_versionstr}")
    unset(_versionstr)
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endmacro()

function(cmakejson_setup_module_dependencies _prefix)
    if(DEFINED ${_prefix})
        set(dep_name ${${_prefix}})
    elseif(DEFINED ${_prefix}_NAME)
        set(dep_name ${${_prefix}_NAME})
    else()
        message(${CMakeJSON_MSG_ERROR_TYPE} "Dependency parsed as '${_prefix}' is missing a name!")
    endif()
endfunction(cmakejson_setup_module_dependencies _prefix)


macro(cmakejson_find_module _contents)
    cmakejson_validate_find_module_json("${_contents}")

    list(APPEND CMAKE_MESSAGE_CONTEXT "parse")
    cmakejson_parse_json(JSON_INPUT "${_input}"
                         VARIABLE_PREFIX "MODULE"
                         OUTPUT_LIST_CREATED_VARIABLES "TARGET_PARSED_VARIABLES"
    )
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
    # Seacrh via config
    if(NOT CMakeJSON_PARSE_MODULE_SKIP_CONFIG_MODE)
        cmakejson_find_package_config()
    endif()
    # Search via pkgconfig or find_library
    if(NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
        find_package(PkgConfig)
        if(PkgConfig_FOUND)
            cmakejson_find_package_pkgconfig()
        endif()
        if(NOT ${CMAKE_FIND_PACKAGE_NAME}_PKGCONFIG)
            foreach(_component IN LISTS ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
                find_package(${CMAKE_FIND_PACKAGE_NAME}_${_component})
            endif()
            cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_MODULE_DEPENDENCIES cmakejson_setup_module_dependencies)
            cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_MODULE_CONFIGURATIONS cmakejson_gather_json_array_configuration_as_list CMakeJSON_MODULE_CONFIGURATIONS)
            if(NOT CMakeJSON_MODULE_CONFIGURATIONS)
                set(CMakeJSON_MODULE_CONFIGURATIONS "DEBUG" "RELEASE")
                set(CMakeJSON_MODULE_DEBUG_LIB_SUFFIXES "d" "_d")
            endif()
            cmakejson_run_func_over_parsed_range(${_prefix}_LIBRARY_NAMES cmakejson_gather_json_array_as_list CMakeJSON_MODULE_LANGUAGES)
            if(NOT CMakeJSON_MODULE_LANGUAGES)
                set(CMakeJSON_MODULE_LANGUAGES "C") # TODO: maybe switch that one the header file ending?
            endif()
            cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_MODULE_IMPORTED_TARGETS cmakejson_create_imported_targets _found_targets)
            find_package_handle_standard_args(${CMAKE_FIND_PACKAGE_NAME} 
                REQUIRED_VARS ${_found_targets}
                #HANDLE_VERSION_RANGE  # TODO: support version extraction from header?
                #VERSION_VAR <somevar>
                HANDLE_COMPONENTS
            )
        else()
            # Pkgconfig available -> All imported targets get redirected to the pkgconfig target
            cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_MODULE_IMPORTED_TARGETS cmakejson_redirect_imported_targets_to_pkgconfig_target "PkgConfig::${CMAKE_FIND_PACKAGE_NAME}_PC")
            find_package_handle_standard_args(  ${CMAKE_FIND_PACKAGE_NAME} 
                                                VERSION_VAR ${CMAKE_FIND_PACKAGE_NAME}_PC_VERSION
                                                HANDLE_VERSION_RANGE
                                             )
        endif()
    endif()
    # Use Fetch_Content / ExternalProject_Add ? CPM or whatever?
    if(NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
        # TODO: Run fetchcontent or external_project_add?
    endif()

    find_package_handle_standard_args(${CMAKE_FIND_PACKAGE_NAME} 
    #HANDLE_VERSION_RANGE  # TODO: support version extraction from header?
    #VERSION_VAR <somevar>
    HANDLE_COMPONENTS
    )
endmacro()

macro(cmakejson_find_module_file _file)
    file(TO_CMAKE_PATH "${_file}" _file)
    get_filename_component(file "${_file}" ABSOLUTE)
    if(NOT EXISTS "${file}")
        message(FATAL_ERROR "File '${_file}' does not exists!")
    endif()
    message(${CMakeJSON_MSG_VERBOSE_TYPE} "Creating target from file: '${_file}'")
    get_filename_component(_filename "${_file}" NAME_WE)
    file(READ "${file}" _contents)
    cmakejson_find_module("${_contents}")
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${file}")
    unset(_contents)
    unset(_filename)
    unset(_file)
    unset(file)
endmacro()