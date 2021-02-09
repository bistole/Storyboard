package config

import "testing"

func TestConfig(t *testing.T) {
	config := NewConfigService("Storyboard")
	if config.GetAppName() != "Storyboard" {
		t.Error("Mismatch app name")
	}
	if config.GetDatabaseName() != "foo.db" {
		t.Error("Mismatch database name")
	}
}
