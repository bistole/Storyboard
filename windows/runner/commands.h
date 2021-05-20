#ifndef RUNNER_COMMANDS_H_
#define RUNNER_COMMANDS_H_

#include <flutter/flutter_engine.h>
#include <flutter/method_channel.h>

using namespace flutter;

class Commands {
public:
    Commands();
    ~Commands();

    void registerMessenger(BinaryMessenger* binary_messenger);

private:
    BinaryMessenger* binary_messenger_;
    MethodChannel<EncodableValue>* method_channel_;

	void setCurrentIP(std::string& ip);
	std::string getCurrentIP();
	std::map<EncodableValue, EncodableValue> getServerIPs();
	std::vector<EncodableValue> openFileDialog(std::string& title, std::vector<std::string>& types);
    bool saveFileDialog(std::string& title, std::string& filename, std::string& mime, std::string& path);
    void methodChannelHandler(
        const MethodCall<EncodableValue>& call,
        std::unique_ptr<MethodResult<EncodableValue>>& result);
};

#endif
