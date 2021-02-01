#include "config.h"
#include "menu_events.h"

#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>

using namespace flutter;

#define MENU_EVENTS "/MENU_EVENTS"
#define MENU_IMPORT_PHOTO "MENU_EVENTS:IMPORT_PHOTO"

MenuEvents::MenuEvents() : binary_messenger_(nullptr) {}

MenuEvents::~MenuEvents()
{
    if (method_channel_) {
        delete method_channel_;
        method_channel_ = nullptr;
    }
}

void MenuEvents::registerMessenger(BinaryMessenger* binary_messenger) {
    binary_messenger_ = binary_messenger;

    std::string channel_name(PACKAGE_NAME);
    channel_name += MENU_EVENTS;

    const StandardMethodCodec& codec = StandardMethodCodec::GetInstance();

    method_channel_ = new MethodChannel<EncodableValue>(
        binary_messenger_, channel_name, &codec);
}

void MenuEvents::importPhoto()
{
    if (method_channel_) {
        method_channel_->InvokeMethod(MENU_IMPORT_PHOTO, nullptr);
    }
}
