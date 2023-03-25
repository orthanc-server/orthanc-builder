# Orthanc - A Lightweight, RESTful DICOM Store
# Copyright (C) 2012-2016 Sebastien Jodogne, Medical Physics
# Department, University Hospital of Liege, Belgium
# Copyright (C) 2017-2023 Osimis S.A., Belgium
# Copyright (C) 2021-2023 Sebastien Jodogne, ICTEAM UCLouvain, Belgium
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


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
