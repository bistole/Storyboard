#include "config.h"
#include "package_info.h"

#include <flutter/standard_method_codec.h>
#include <flutter/method_codec.h>

#include <tchar.h>
#include <windows.h>

#include <string>
#include <iostream>

using namespace std;

PackageInfo::PackageInfo()
{
	binary_messenger_ = nullptr;
}

PackageInfo::~PackageInfo()
{
	if (method_channel_ != nullptr) {
		delete method_channel_;
		method_channel_ = nullptr;
	}
}

void PackageInfo::registerMessenger(BinaryMessenger* binary_messenger)
{
	const std::string& channel_name("plugins.flutter.io/package_info");
	const StandardMethodCodec& codec = StandardMethodCodec::GetInstance();
	method_channel_ = new MethodChannel<EncodableValue>(binary_messenger, channel_name, &codec);

	method_channel_->SetMethodCallHandler([this](
		const MethodCall<EncodableValue>& call,
		std::unique_ptr<MethodResult<EncodableValue>> result) {
		this->methodChannelHandler(call, result);
	});
}

void PackageInfo::methodChannelHandler(
	const MethodCall<EncodableValue>& call,
	std::unique_ptr<MethodResult<EncodableValue>>& result)
{
	if (call.method_name().compare("getAll") == 0) {
		cout << "receive getAll action\n";

		std::string appName(APP_NAME);
		std::string packageName(PACKAGE_NAME);
		std::string appVersion(APP_VERSION);
		std::string buildNumber(BUILD_NUMBER);

		std::map<EncodableValue, EncodableValue> map = {
			{"appName", appName},
			{"packageName", packageName},
			{"version", appVersion},
			{"buildNumber", appVersion},
		};
		result->Success(map);
	}
}

