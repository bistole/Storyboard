#include "menu.h"

#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>

using namespace flutter;

const std::string& MENU_IMPORT_PHOTO = "MENU_EVENTS:IMPORT_PHOTO";

Menu::Menu()
{
	binary_messenger_ = nullptr;
}

Menu::~Menu()
{
	delete method_channel_;
	method_channel_ = nullptr;
}

void Menu::registerMessager(BinaryMessenger* binary_messenger) {
	binary_messenger_ = binary_messenger;

	std::string channel_name("test/channel");
	const StandardMethodCodec& codec = StandardMethodCodec::GetInstance();

	method_channel_ = new MethodChannel<EncodableValue>(binary_messenger_, channel_name, &codec);
}

void Menu::importPhoto()
{
	if (method_channel_) {
		method_channel_->InvokeMethod(	MENU_IMPORT_PHOTO, nullptr);
	}
}
