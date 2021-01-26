#ifndef RUNNER_MENU_EVENTS_H_
#define RUNNER_MENU_EVENTS_H_

#include <flutter/flutter_engine.h>
#include <flutter/method_channel.h>

using namespace flutter;

class MenuEvents {
public:
	MenuEvents();
	~MenuEvents();

	void registerMessenger(BinaryMessenger* binary_messenger);
	void importPhoto();

private:
	BinaryMessenger* binary_messenger_;
	MethodChannel<EncodableValue>* method_channel_;
};

#endif
