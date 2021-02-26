
message(STATUS "You found me! As '${CMAKE_FIND_PACKAGE_NAME}'")
set_package_properties(${CMAKE_FIND_PACKAGE_NAME} PROPERTIES DESCRIPTION "Try finding ME!")
set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)

#TODO: Create Find<Package>.json