#ifndef RUNNER_MENU_H_
#define RUNNER_MENU_H_

#include <flutter/flutter_engine.h>
#include <flutter/method_channel.h>

using namespace flutter;

class Menu {
public:
	Menu();
	~Menu();

	void registerMessager(BinaryMessenger* binary_messenger);
	void importPhoto();

private:
	BinaryMessenger* binary_messenger_;
	MethodChannel<EncodableValue>* method_channel_;
};

#endif
