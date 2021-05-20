#include "config.h"
#include "utils.h"
#include "commands.h"
#include "struct_mapping/struct_mapping.h"
#include "backend/libBackend.h"

#include <stdio.h>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include "windows.h"
#define STRICT_TYPED_ITEMIDS
#include "ShlObj.h"
#include "objbase.h"
#include "ShObjIdl.h"
#include "shlwapi.h"
#include <knownfolders.h> // for KnownFolder APIs/datatypes/function headers
#include <propvarutil.h>  // for PROPVAR-related functions
#include <propkey.h>      // for the Property key APIs/datatypes
#include <propidl.h>      // for the Property System APIs
#include <strsafe.h>      // for StringCchPrintfW
#include "shtypes.h"

#include <flutter/standard_method_codec.h>

#define COMMANDS 			"/COMMANDS"
#define CMD_OPEN_DIALOG 	"CMD:OPEN_DIALOG"
#define CMD_SHARE_OUT_PHOTO "CMD:SHARE_OUT_PHOTO"
#define CMD_SHARE_OUT_TEXT	"CMD:SHARE_OUT_TEXT"


Commands::Commands() : binary_messenger_(nullptr), method_channel_(nullptr) {}

Commands::~Commands() {
    binary_messenger_ = nullptr;
    if (method_channel_ != nullptr) {
        delete method_channel_;
        method_channel_ = nullptr;
    }
}

void Commands::registerMessenger(BinaryMessenger* binary_messenger)
{
    std::string channel_name(PACKAGE_NAME);
    channel_name += COMMANDS;

    const StandardMethodCodec& codec = StandardMethodCodec::GetInstance();
    method_channel_ = new MethodChannel<EncodableValue>(binary_messenger, channel_name, &codec);

    method_channel_->SetMethodCallHandler([this](
        const MethodCall<EncodableValue>& call,
        std::unique_ptr<MethodResult<EncodableValue>> result) {
        this->methodChannelHandler(call, result);
    });
}

std::vector<EncodableValue> Commands::openFileDialog(std::string& title, std::vector<std::string>& types) {
	// Initialize
	std::vector<EncodableValue> result{};

	HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
	if (SUCCEEDED(hr)) {

		// Get Dialog Handler
		IFileOpenDialog* pFileOpen;
		hr = CoCreateInstance(CLSID_FileOpenDialog, NULL, CLSCTX_ALL, IID_IFileOpenDialog,
			reinterpret_cast<void**>(&pFileOpen));
		if (SUCCEEDED(hr)) {

			// Show Dialog
			PWSTR pTitle = ConvertString2LPWSTR(title);
			pFileOpen->SetTitle(pTitle);

			COMDLG_FILTERSPEC* wtypes = (COMDLG_FILTERSPEC*)malloc(types.size() * sizeof(COMDLG_FILTERSPEC));
			for (int idx = 0; idx < types.size(); idx++) {
				LPWSTR name = ConvertString2LPWSTR(types[idx]);
				std::string strSpec = std::string("*.") + types[idx];
				LPWSTR spec = ConvertString2LPWSTR(strSpec);
				wtypes[idx].pszName = name;
				wtypes[idx].pszSpec = spec;
			}
			pFileOpen->SetFileTypes((unsigned)types.size(), wtypes);
			pFileOpen->SetOptions(FOS_ALLOWMULTISELECT);
			pFileOpen->Show(NULL);
			if (SUCCEEDED(hr)) {
				// Get File Names

				IShellItemArray* pItemArray;
				hr = pFileOpen->GetResults(&pItemArray);
				if (SUCCEEDED(hr)) {
					DWORD cnt;
					pItemArray->GetCount(&cnt);
					for (DWORD idx = 0; idx < cnt; idx++) {
						IShellItem* pItem;
						hr = pItemArray->GetItemAt(idx, &pItem);
						if (SUCCEEDED(hr)) {
							PWSTR pwszFilePath;
							hr = pItem->GetDisplayName(SIGDN_FILESYSPATH, &pwszFilePath);
							if (SUCCEEDED(hr)) {
								int size = WideCharToMultiByte(CP_UTF8, 0, pwszFilePath, -1,
									NULL, 0, NULL, NULL);
								if (size > 0) {
									PSTR pszFilePath = (char*)malloc((size + 1) * sizeof(CHAR));
									pszFilePath[size] = '\0';
									WideCharToMultiByte(CP_UTF8, 0, pwszFilePath, -1,
										pszFilePath, size, NULL, NULL);
									std::stringstream file;
									file << pszFilePath;
									result.push_back(EncodableValue(file.str()));
									std::cout << "Got file:" << file.str() << std::endl;
									free(pszFilePath);
								}
								CoTaskMemFree(pwszFilePath);
							}
						}
					}
					pItemArray->Release();
				}
			}
			// release types
			for (int idx = 0; idx < types.size(); idx++) {
				free((void*)(wtypes[idx].pszName));
				free((void*)(wtypes[idx].pszSpec));
			}
			free(wtypes);
			pFileOpen->Release();
		}
		CoUninitialize();
	}
	return result;
}

bool Commands::saveFileDialog(std::string& title, std::string& filename, std::string& mime, std::string& path) {
	// Get Dialog Handler
	HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
	if (SUCCEEDED(hr)) {
		IFileSaveDialog* pFileSave;

		hr = CoCreateInstance(CLSID_FileSaveDialog, NULL, CLSCTX_ALL, IID_IFileSaveDialog,
			reinterpret_cast<void**>(&pFileSave));
		if (SUCCEEDED(hr)) {

			// Show Dialog
			PWSTR pTitle = ConvertString2LPWSTR(title);
			pFileSave->SetTitle(pTitle);

			DWORD dwFlags;
			hr = pFileSave->GetOptions(&dwFlags);

			if (SUCCEEDED(hr)) {
				hr = pFileSave->SetOptions(dwFlags | FOS_FORCEFILESYSTEM);

				if (SUCCEEDED(hr)) {
					hr = pFileSave->SetDefaultExtension(L"jpeg");

					hr = pFileSave->Show(NULL);
					if (SUCCEEDED(hr)) {

						IShellItem* psiResult;
						hr = pFileSave->GetResult(&psiResult);
						if (SUCCEEDED(hr))
						{
							PWSTR pwszFilePath = NULL;
							hr = psiResult->GetDisplayName(SIGDN_FILESYSPATH, &pwszFilePath);
							if (SUCCEEDED(hr)) {
								printf("dialog is ok");
								// TODO: copy file
								int size = WideCharToMultiByte(CP_UTF8, 0, pwszFilePath, -1,
									NULL, 0, NULL, NULL);
								if (size > 0) {
									PSTR pszFilePath = (char*)malloc((size + 1) * sizeof(CHAR));
									pszFilePath[size] = '\0';
									WideCharToMultiByte(CP_UTF8, 0, pwszFilePath, -1,
										pszFilePath, size, NULL, NULL);
									std::stringstream file;
									file << pszFilePath;
									// result.push_back(EncodableValue(file.str()));
									std::cout << "Got file:" << file.str() << std::endl;
									free(pszFilePath);
								}
								CoTaskMemFree(pwszFilePath);
							}
						}
					}
				}
			}
		}
	}

	return false;
}

void Commands::methodChannelHandler(
    const MethodCall<EncodableValue>& call,
    std::unique_ptr<MethodResult<EncodableValue>>& result)
{
    const std::string& method_name = call.method_name();
    if (method_name.compare(CMD_OPEN_DIALOG) == 0) {
        printf("CMD_OPEN_DIALOG\n");
		const EncodableValue* value = call.arguments();
		if (std::holds_alternative<EncodableMap>(*value)) {
			EncodableMap map = std::get<EncodableMap>(*value);
			std::cout << "running to get arguments:" << map.size() << std::endl;
			std::string strTitle = std::string("Import Files");
			std::string strTypes = std::string("*");
			for (auto [key, val] : map) {
				if (std::holds_alternative<std::string>(key)) {
					std::string strKey = std::get<std::string>(key);
					if (strKey.compare("title") == 0) {
						strTitle = std::holds_alternative<std::string>(val)
							? std::get<std::string>(val) : "Import Files";
						std::cout << strTitle << std::endl;
					}
					else if (strKey.compare("types") == 0) {
						strTypes = std::holds_alternative<std::string>(val)
							? std::get<std::string>(val) : "*";
						std::cout << strTypes << std::endl;
					}
				}
			}
			std::vector<std::string> vecTypes{};
			SplitStringIntoVector(strTypes, ';', vecTypes);
			std::cout << vecTypes.size() << std::endl;

			std::vector<EncodableValue> files = this->openFileDialog(strTitle, vecTypes);
			return result->Success(files);
		}
		result->Success({});
	}
	else if (method_name.compare(CMD_SHARE_OUT_PHOTO) == 0) {
		printf("CMD_SHARE_OUT_PHOTO\n");
		const EncodableValue* value = call.arguments();
		if (std::holds_alternative<EncodableList>(*value)) {
			EncodableList list = std::get<EncodableList>(*value);
			if (list.size() == 3) {
				std::string name = std::holds_alternative<std::string>(list.at(0)) 
					? std::get<std::string>(list.at(0)) : std::string("");
				std::string mime = std::holds_alternative<std::string>(list.at(1))
					? std::get<std::string>(list.at(1)) : std::string("");
				std::string path = std::holds_alternative<std::string>(list.at(2))
					? std::get<std::string>(list.at(2)) : std::string("");
				std::string title = std::string("export file");
				bool ret = this->saveFileDialog(title, name, mime, path);
				return result->Success(ret);
			}
		}

	}
}
