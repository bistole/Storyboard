#ifndef RUNNER_PACKAGE_INFO_H_
#define RUNNER_PACKAGE_INFO_H_

#include <flutter/binary_messenger.h>
#include <flutter/method_channel.h>
#include <flutter/encodable_value.h>

using namespace flutter;

class PackageInfo {
public:
    PackageInfo();
    ~PackageInfo();

    void registerMessenger(BinaryMessenger *binary_messenger);
private:
    BinaryMessenger* binary_messenger_;
    MethodChannel<EncodableValue>* method_channel_;

    void methodChannelHandler(
        const MethodCall<EncodableValue>& call,
        std::unique_ptr<MethodResult<EncodableValue>>& result);
};

#endif