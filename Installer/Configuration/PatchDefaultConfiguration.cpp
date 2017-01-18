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

    std::string configuration;
    ReadFile(configuration, "orthanc.json");

    configuration = boost::regex_replace(
      configuration,
      boost::regex("\"(Storage|Index)Directory\" : \"OrthancStorage\""),
      "\"\\1Directory\" : \"" + Escape(storageDir) + "\"");
  
    configuration = boost::regex_replace(
      configuration,
      boost::regex("\"Plugins\" : \\[\\s*\\]"),
      "\"Plugins\" : [ \"../Plugins/\" ]");
  
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
