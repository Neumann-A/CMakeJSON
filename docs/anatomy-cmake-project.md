
## The anatomy of every CMake project
 1) Define toplevel project
 3) (Define subprojects)
 4) Import some (optional) dependencies (via find_package)
 5) Define 'buildable' targets (libraries, executables, others [including code generators] )
 6) Add something to those targets dependendent on some options or the found dependencies (sources,definitions,linkage,etc.)
 ---
 7) install some (not necessary all) targets (sometimes forgotten)
 8) export the installed targets of the project into a cmake file. (probably forgotten)
 9) generate a config including the file from 8) with a find_dependency call for all required dependencies and write a version file (probably forgotten)
 10) maybe restart with 1)

 ### Common problems from the view of package manager
 
 To point 4)
 - having optional dependencies without an explicit option to enable disable the option.
 Observed Problems:
 - Link errors in static builds due to missing dependencies; Builds on different machine not reproduciable due to different system libraries.  
 Solution:
 - Have an explicit named option `<ProjectName>_ENABLE_<PackageName>` which is defaulted to `OFF`
   (Yes there is `CMAKE_DISABLE_FIND_PACKAGE_<PackageName>` but this requires implicit knowledge that the project uses `<PackageName>`)
 - Define `find_package` dependencies on the project levels. Helps integrating those information into the later generated config file. 

### Common problems from the view of the author
 To point 6)
  - linking imported targets without knowledge where they came from. 
 Observed Problems:
  - missing find_dependency call in `<PackageName>Config.cmake` (if it even exits)
 Solution: 
  - 
