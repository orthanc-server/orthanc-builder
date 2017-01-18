cmake_minimum_required (VERSION 2.8)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/../Resources/CMake/MinGW-W64-Toolchain32.cmake)
project(WindowsService)

set(ALLOW_DOWNLOADS ON)
set(STATIC_BUILD ON)

include(CheckLibraryExists)
include(${CMAKE_SOURCE_DIR}/../Resources/CMake/Compiler.cmake)
include(${CMAKE_SOURCE_DIR}/../Resources/CMake/DownloadPackage.cmake)
include(${CMAKE_SOURCE_DIR}/../Resources/CMake/BoostConfiguration.cmake)

add_definitions(
  -DSERVICE_NAME="Orthanc"
  )

add_library(Toolbox STATIC
  Toolbox.cpp
  ${BOOST_SOURCES}
  )

add_executable(OrthancService 
  WindowsService.cpp
  )

add_executable(PatchDefaultConfiguration
  PatchDefaultConfiguration.cpp
  )

target_link_libraries(OrthancService Toolbox)
target_link_libraries(PatchDefaultConfiguration Toolbox)

get_property(OrthancServiceLocation TARGET OrthancService PROPERTY LOCATION)
get_property(PatchDefaultConfigurationLocation TARGET PatchDefaultConfiguration PROPERTY LOCATION)

add_custom_command(TARGET OrthancService
  POST_BUILD
  COMMAND i686-w64-mingw32-strip ${OrthancServiceLocation}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  COMMENT "Stripping the symbols from the Windows service" VERBATIM
  )

add_custom_command(TARGET PatchDefaultConfiguration
  POST_BUILD
  COMMAND i686-w64-mingw32-strip ${PatchDefaultConfigurationLocation}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  COMMENT "Stripping the symbols from the configuration generator" VERBATIM
  )
