# CMakeJSON
CMakeJSON provides a way to declare CMake projects and targets via `*.json` files. Furthermore, it also automatically export your targets and keeps track of your dependencies to generate correct `<PackageName>Config.cmake` files for `find_package` to simply work for your project/package. 

### Usage
The recommended way to use CMakeJSON is to include it as a submodule in your project and use `include(<submodulepath>/CMakeJSON/CMakeJSON.cmake)`.
CMakeJSON is based on the experince with [CMakeCS](https://github.com/Neumann-A/CMakeCommonSetup/) and the newly added JSON parser to CMake. Due to that a CMake version of at least 3.19 is required.


---
## Documentation
List of json members allowed for:
 - [projects](docs/project.md)
 - [targets](docs/targets.md)
 - To implement: [`Find<PackageName>.cmake`](docs/find.md)

Other questions might be answered in the [FAQ](docs/faq.md) 

---
## Quickstart

Examples for using CMakeJSON can be found in [examples](examples).
The simplest CMakeJSON project looks like this:


1. CMakeLists.txt:
    ```
    cmake_minimum_required(VERSION 3.19)
    set(CMakeJSON_ENABLE_PROJECT_OVERRIDE ON) # defines a macro called project() to silence a CMake Warning
    include("${CMAKE_CURRENT_SOURCE_DIR}/CMakeJSON/CMakeJSON.cmake")
    project("<projectname>.json")
    # alternativly: if you don't want to use CMakeJSON_ENABLE_PROJECT_OVERRIDE
    # project(something) # this project call is mandatory since CMake throws a dev warning otherwise
    # cmakejson_project_file("<projectname>.json")
    ```
2. \<projectname\>.json read via `cmakejson_project_file(<filename>)`:
    ```
    {
        "homepage" : "<someurl>",
        "description" : "<somedescription>",
        "version" : "0.1.0",
        "languages" : ["CXX"],
        "list" : [
            "<libname>.target.json"
        ]
    }
    ```

3. \<libname\>.target.json read via `cmakejson_target_file(<filename>)`:
    ```
    {
        "target_type" : "library",
        "sources" : [
            "src/somesource.cpp"
        ]
    }
    ```
---

## Key features
 - JSON based project/target definitions
 - CMake variable expansion in JSON members
 - Getting target/project name from JSON file.
 - Mixing of JSON files and normal CMake. 
 - Automatic `<PackageName>Config(Version).cmake` generation

In the future:
 - Automatic pc file generation.
 - More Awesome stuff
 - Things from the [ToDo List](docs/todo.md) 

---
### Examples
Different Examples for using CMakeJSON can be found in [examples](examples).

---
### Internals
