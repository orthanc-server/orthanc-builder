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


#include "Toolbox.h"

std::wstring GetStringRegKey(const std::wstring& key, 
                             const std::wstring& name, 
                             const std::wstring& defaultValue)
{
  HKEY hKey;
  if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, key.c_str(), 0, KEY_READ, &hKey) != ERROR_SUCCESS)
  {
    return defaultValue;
  }

  WCHAR szBuffer[512];
  DWORD dwBufferSize = sizeof(szBuffer);
  if (RegQueryValueExW(hKey, name.c_str(), 0, NULL, (LPBYTE)szBuffer, &dwBufferSize) != ERROR_SUCCESS)
  {
    RegCloseKey(hKey);
    return defaultValue;
  }

  RegCloseKey(hKey);
  return szBuffer;
}


std::string GetStringRegKeyAnsi(const std::string& key, 
                                const std::string& name, 
                                const std::string& defaultValue)
{
  HKEY hKey;
  if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, key.c_str(), 0, KEY_READ, &hKey) != ERROR_SUCCESS)
  {
    return defaultValue;
  }

  CHAR szBuffer[512];
  DWORD dwBufferSize = sizeof(szBuffer);
  if (RegQueryValueExA(hKey, name.c_str(), 0, NULL, (LPBYTE)szBuffer, &dwBufferSize) != ERROR_SUCCESS)
  {
    RegCloseKey(hKey);
    return defaultValue;
  }

  RegCloseKey(hKey);
  return szBuffer;
}


DWORD GetDWordRegKey(const std::wstring& key, 
                     const std::wstring& name, 
                     DWORD defaultValue)
{
  HKEY hKey;
  if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, key.c_str(), 0, KEY_READ, &hKey) != ERROR_SUCCESS)
  {
    return defaultValue;
  }

  DWORD dwBufferSize(sizeof(DWORD));
  DWORD nResult(0);
  if (RegQueryValueExW(hKey, name.c_str(), 0, NULL, 
                       reinterpret_cast<LPBYTE>(&nResult), &dwBufferSize) != ERROR_SUCCESS)
  {
    RegCloseKey(hKey);
    return defaultValue;
  }

  RegCloseKey(hKey);
  return nResult;
}
