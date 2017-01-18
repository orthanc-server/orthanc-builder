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
