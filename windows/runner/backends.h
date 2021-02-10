#ifndef RUNNER_BACKENDS_H_
#define RUNNER_BACKENDS_H_

#include <flutter/flutter_engine.h>
#include <flutter/method_channel.h>

using namespace flutter;

class Backends {
public:
    Backends();
    ~Backends();

    void registerMessenger(BinaryMessenger* binary_messenger);

private:
    BinaryMessenger* binary_messenger_;
    MethodChannel<EncodableValue>* method_channel_;

    std::string getHomeDir();
	void setCurrentIP(std::string& ip);
	std::string getCurrentIP();
	std::map<EncodableValue, EncodableValue> getServerIPs();

    void methodChannelHandler(
        const MethodCall<EncodableValue>& call,
        std::unique_ptr<MethodResult<EncodableValue>>& result);
};

#endif
