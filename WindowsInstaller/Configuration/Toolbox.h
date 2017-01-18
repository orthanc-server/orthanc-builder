#pragma once

#include <string>
#include <windows.h>

std::wstring GetStringRegKey(const std::wstring& key, 
                             const std::wstring& name, 
                             const std::wstring& defaultValue);

std::string GetStringRegKeyAnsi(const std::string& key, 
                                const std::string& name, 
                                const std::string& defaultValue);

DWORD GetDWordRegKey(const std::wstring& key, 
                     const std::wstring& name, 
                     DWORD defaultValue);
