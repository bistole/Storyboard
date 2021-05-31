#include "config.h"
#include "utils.h"

#include <flutter_windows.h>
#include <io.h>
#include <stdio.h>
#include "windows.h"
#include "ShlObj.h"

#include <sstream>
#include <iostream>

void CreateAndAttachConsole() {
  if (::AllocConsole()) {
    FILE *unused;
    if (freopen_s(&unused, "CONOUT$", "w", stdout)) {
      _dup2(_fileno(stdout), 1);
    }
    if (freopen_s(&unused, "CONOUT$", "w", stderr)) {
      _dup2(_fileno(stdout), 2);
    }
    std::ios::sync_with_stdio();
    FlutterDesktopResyncOutputStreams();
  }
}

std::vector<std::string> GetCommandLineArguments() {
  // Convert the UTF-16 command line arguments to UTF-8 for the Engine to use.
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return std::vector<std::string>();
  }

  std::vector<std::string> command_line_arguments;

  // Skip the first argument as it's the binary name.
  for (int i = 1; i < argc; i++) {
    command_line_arguments.push_back(Utf8FromUtf16(argv[i]));
  }

  ::LocalFree(argv);

  return command_line_arguments;
}

std::string GetEnvDir() {
#ifdef _DEBUG 
  return "debug";
#elif defined(_PROFILE)
  return "profile";
#else 
  return "release";
#endif
}

std::string GetHomeDir() {
  TCHAR szPath[MAX_PATH];
  HRESULT hr = SHGetFolderPath( NULL, CSIDL_COMMON_APPDATA, NULL, 0, szPath );
  if (SUCCEEDED(hr)) {
    std::string* strPath = ConvertLPWSTR2String(szPath);
    if (strPath != NULL) {
        std::string fullpath = *strPath + "\\" + PACKAGE_NAME + "\\" + this->GetEnvDir();
        return fullpath;
    }
  }
  return NULL;
}

std::string Utf8FromUtf16(const wchar_t* utf16_string) {
  if (utf16_string == nullptr) {
    return std::string();
  }
  int target_length = ::WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string,
      -1, nullptr, 0, nullptr, nullptr);
  if (target_length == 0) {
    return std::string();
  }
  std::string utf8_string;
  utf8_string.resize(target_length);
  int converted_length = ::WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string,
      -1, utf8_string.data(),
      target_length, nullptr, nullptr);
  if (converted_length == 0) {
    return std::string();
  }
  return utf8_string;
}

void SplitStringIntoVector(std::string str, char delimiter, std::vector<std::string>& out) {
    std::istringstream stream(str);
    std::string s;
    out.clear();
    while (std::getline(stream, s, ';')) {
        if (s.length() > 0) {
            out.push_back(s);
        }
    }
}

std::string *ConvertLPWSTR2String(wchar_t* pwszStr) {
    int size = WideCharToMultiByte(CP_UTF8, 0, pwszStr, -1,
        NULL, 0, NULL, NULL);
    if (size > 0) {
        char* pszStr = (CHAR*)malloc((size + 1) * sizeof(CHAR));
        pszStr[size] = '\0';
        WideCharToMultiByte(CP_UTF8, 0, pwszStr, -1, pszStr, size, NULL, NULL);
        std::string* str = new std::string(pszStr);
        free(pszStr);
        return str;
    }
    return NULL;
}

wchar_t* ConvertString2LPWSTR(std::string& str) {
    int size = MultiByteToWideChar(CP_UTF8, 0, str.c_str(), -1, NULL, 0);
    if (size > 0) {
        wchar_t* pwszStr = (wchar_t*)malloc((size + 1) * sizeof(wchar_t));
        MultiByteToWideChar(CP_UTF8, 0, str.c_str(), -1, pwszStr, size);
        return pwszStr;
    }
    return NULL;
}