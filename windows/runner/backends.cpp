#include "config.h"
#include "utils.h"
#include "backends.h"
#include "struct_mapping/struct_mapping.h"
#include "backend/libBackend.h"

#include <stdio.h>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <shlobj.h>

#include <flutter/standard_method_codec.h>

#define BACKENDS            "/BACKENDS"
#define BK_GET_DATAHOME     "BK:GET_DATA_HOME"
#define BK_GET_CURRENT_IP   "BK:GET_CURRENT_IP"
#define BK_SET_CURRENT_IP   "BK:SET_CURRENT_IP"
#define BK_GET_SERVER_IPS   "BK:GET_SERVER_IPS"

Backends::Backends() : binary_messenger_(nullptr), method_channel_(nullptr) {}

Backends::~Backends() {
    binary_messenger_ = nullptr;
    if (method_channel_ != nullptr) {
        delete method_channel_;
        method_channel_ = nullptr;
    }
}

void Backends::registerMessenger(BinaryMessenger* binary_messenger)
{
    std::string channel_name(PACKAGE_NAME);
    channel_name += BACKENDS;

    const StandardMethodCodec& codec = StandardMethodCodec::GetInstance();
    method_channel_ = new MethodChannel<EncodableValue>(binary_messenger, channel_name, &codec);

    method_channel_->SetMethodCallHandler([this](
        const MethodCall<EncodableValue>& call,
        std::unique_ptr<MethodResult<EncodableValue>> result) {
        this->methodChannelHandler(call, result);
    });
}

std::string Backends::getHomeDir() {
    TCHAR szPath[MAX_PATH];

    HRESULT hr = SHGetFolderPath( NULL, CSIDL_COMMON_APPDATA, NULL, 0, szPath ) 
    if (SUCCEEDED(hr)) {
        return szPath + PACKAGE_NAME;
    }
    return NULL
}

std::string Backends::getCurrentIP() {
	char* ip = Backend_GetCurrentIP();
	// char *ip = "127.0.0.1";
	std::string ipstr(ip);
	return ipstr;
}

void Backends::setCurrentIP(std::string & ip) {
	const char* ipchar = ip.c_str();
	char* ipcharDump = _strdup(ipchar);
	printf("CMD_SET_CURRENT_IP: %s\n", ipcharDump);
	Backend_SetCurrentIP(ipcharDump);
	free(ipcharDump);
}

std::map<EncodableValue, EncodableValue> Backends::getServerIPs() {
	struct IPS {
		std::map<std::string, std::string> ips;
	};

	struct_mapping::reg(&IPS::ips, "ips");
	IPS ipsStruct;

	// const char* ips = "{\"en0\":\"127.0.0.1\"}";
	const char* ips = Backend_GetAvailableIPs();
	std::string ipstr = std::string("{\"ips\":") + ips + std::string("}");
	std::cout << "CMD_GET_SERVER_IPS:" << ipstr << std::endl;
	std::istringstream json_data(ipstr);

	struct_mapping::map_json_to_struct(ipsStruct, json_data);
	std::map<EncodableValue, EncodableValue> map;
	for (auto [name, ip] : ipsStruct.ips) {
		map[name] = ip;
		std::cout << name << ":" << ip << std::endl;
	}
	return map;
}

void Backends::methodChannelHandler(
    const MethodCall<EncodableValue>& call,
    std::unique_ptr<MethodResult<EncodableValue>>& result)
{
    const std::string& method_name = call.method_name();
    if (method_name.compare(BK_GET_DATAHOME) == 0) {
        printf("BK_GET_DATAHOME\n");
        std::string path = this->getHomeDir();
        result->Success(path);
    } else if (method_name.compare(BK_GET_CURRENT_IP) == 0) {
        printf("BK_GET_CURRENT_IP\n");
		std::string ipstr = this->getCurrentIP();
		result->Success(ipstr);
    } else if (method_name.compare(BK_SET_CURRENT_IP) == 0) {
		printf("BK_SET_CURRENT_IP\n");
		const EncodableValue* value = call.arguments();
		if (std::holds_alternative<std::string>(*value)) {
			std::string ip = std::get<std::string>(*value);
			this->setCurrentIP(ip);
		}
    } else if (method_name.compare(BK_GET_SERVER_IPS) == 0) {
		printf("BK_GET_SERVER_IPS\n");
		std::map<EncodableValue, EncodableValue> map = this->getServerIPs();
		result->Success(map);
	}
}
