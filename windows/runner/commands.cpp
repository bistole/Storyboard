#include "config.h"
#include "commands.h"
#include "struct_mapping/struct_mapping.h"

#include <stdio.h>

#include <flutter/standard_method_codec.h>

#define COMMANDS "/COMMANDS"
#define CMD_OPEN_DIALOG "CMD:OPEN_DIALOG"
#define CMD_GET_CURRENT_IP "CMD:GET_CURRENT_IP"
#define CMD_SET_CURRENT_IP "CMD:SET_CURRENT_IP"
#define CMD_GET_SERVER_IPS "CMD:GET_SERVER_IPS"

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

void Commands::methodChannelHandler(
	const MethodCall<EncodableValue>& call,
	std::unique_ptr<MethodResult<EncodableValue>>& result)
{
    const std::string& method_name = call.method_name();
	if (method_name.compare(CMD_OPEN_DIALOG) == 0) {
        printf("CMD_OPEN_DIALOG\n");
    } else if (method_name.compare(CMD_GET_CURRENT_IP) == 0) {
        printf("CMD_GET_CURRENT_IP\n");
		char *ip = "127.0.0.1";
		result->Success(app);
    } else if (method_name.compare(CMD_SET_CURRENT_IP) == 0) {
		std::string& ip = call.arguments;
		char *ipchar = ip.c_str();
        printf("CMD_SET_CURRENT_IP: %s\n", ipchar);
    } else if (method_name.compare(CMD_GET_SERVER_IPS) == 0) {
		char *ips = "{}";
		std::map<std::string, std::string> map;
		struct_mapping::map_json_to_struct(map, ips);
		printf("CMD_GET_SERVER_IPS: %v\n", map);
		result->Success(map);
	}
}
