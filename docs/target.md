## Supported/Used JSON members in target JSON
 - `condition` : Condition to include/parse/setup the target
 - `name` (default: `get_filename_component(NAME_WE)` : Name of the target
 - `target_type` : Type of the target on of `library|executable|custom_target`
 - `parameters` : Parameters to add to the target generation of `target_type` (Use this especially for `custom_target`)
 - `sources` : Sources to pass directly at the end of `add_<target_type>` command
 - `add_dependencies` : other target dependencies to add to the target
 - `export` (default: `ON` except for `OBJECT` libraries and `custom_targets`): Export target
 - `public_headers` (experimental) : list of public headers
 - `properties` : List of properties to set on the target. submembers of array elements: `name`, `value`, `append_option`
 - `target_install_parameters`: Custom parameters to pass `install(TARGETS)`. (Note: Don't pass export parameters! These are handled by CMakeJSON)

All the below do the same as `target_<one of the below>` applied to the target
 - `compile_definitions`
 - `compile_features`
 - `compile_options`
 - `include_directories`
 - `link_directories`
 - `link_libraries`
 - `link_options`
 - `precompile_headers`
 - `target_sources`

each of these members can contain the following submembers which are arrays:
 - `private`
 - `interface`
 - `public`