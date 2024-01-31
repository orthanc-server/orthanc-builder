/**
 * Orthanc - A Lightweight, RESTful DICOM Store
 * Copyright (C) 2012-2016 Sebastien Jodogne, Medical Physics
 * Department, University Hospital of Liege, Belgium
 * Copyright (C) 2017-2024 Osimis S.A., Belgium
 * Copyright (C) 2021-2024 Sebastien Jodogne, ICTEAM UCLouvain, Belgium
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 **/


#include <boost/filesystem.hpp>
#include <boost/regex.hpp>
#include <iostream>

#include "Toolbox.h"


static std::streamsize GetStreamSize(std::istream& f)
{
  // http://www.cplusplus.com/reference/iostream/istream/tellg/
  f.seekg(0, std::ios::end);
  std::streamsize size = f.tellg();
  f.seekg(0, std::ios::beg);

  return size;
}


static void ReadFile(std::string& content,
                     const std::string& path) 
{
  boost::filesystem::ifstream f;
  f.open(path, std::ifstream::in | std::ifstream::binary);
  if (!f.good())
  {
    throw std::runtime_error("Cannot open file");
  }

  std::streamsize size = GetStreamSize(f);
  content.resize(size);
  if (size != 0)
  {
    f.read(reinterpret_cast<char*>(&content[0]), size);
  }

  f.close();
}


static void WriteFile(const void* content,
                      size_t size,
                      const std::string& path)
{
  boost::filesystem::ofstream f;
  f.open(path, std::ofstream::out | std::ofstream::binary);
  if (!f.good())
  {
    throw std::runtime_error("Cannot write file");
  }

  if (size != 0)
  {
    f.write(reinterpret_cast<const char*>(content), size);

    if (!f.good())
    {
      f.close();
      throw std::runtime_error("Cannot write file");
    }
  }

  f.close();
}



static std::string Escape(const std::string& s)
{
  std::string result;

  for (size_t i = 0; i < s.size(); i++)
  {
    if (s[i] == '"')
    {
      result += "\\\\\"";
    }
    else if (s[i] == '\\')
    {
      result += "\\\\\\\\";
    }
    else
    {
      result += s[i];
    }
  }

  return result;
}


int main()
{
  try
  {
    std::string storageDir = GetStringRegKeyAnsi
      ("SOFTWARE\\Orthanc\\Orthanc Server", "OrthancDir", "");

    std::string installDir = GetStringRegKeyAnsi
      ("SOFTWARE\\Orthanc\\Orthanc Server", "InstallDir", "");

    std::string configuration;
    ReadFile(configuration, "orthanc.json");

    configuration = boost::regex_replace(
      configuration,
      boost::regex("\"(Storage|Index)Directory\" : \"OrthancStorage\""),
      "\"\\1Directory\" : \"" + Escape(storageDir) + "\"");
  
    configuration = boost::regex_replace(
      configuration,
      boost::regex("\"Plugins\" : \\[\\s*\\]"),
      "\"Plugins\" : [ \"" + Escape(installDir + "\\Plugins") + "\" ]");
  
    configuration = boost::regex_replace(
      configuration,
      boost::regex("\"HttpsCACertificates\" : \"\""),
      "\"HttpsCACertificates\" : \"" + Escape(installDir + "\\Configuration\\ca-certificates.crt") + "\"");
    
    WriteFile(configuration.c_str(), configuration.size(), "orthanc.json");
    std::cerr << "Successfully patched the default Orthanc configuration" << std::endl;
  
    return 0;
  }
  catch (...)
  {
    std::cerr << "ERROR: Cannot patch the default Orthanc configuration" << std::endl;
    return -1;
  }
}
