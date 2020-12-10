package config

import "testing"

func TestConfig(t *testing.T) {
	config := NewConfigService()
	if config.GetVendorName() != "Laterhorse" {
		t.Error("Mismatch vendor name")
	}
	if config.GetAppName() != "Storyboard" {
		t.Error("Mismatch app name")
	}
	if config.GetDatabaseName() != "foo.db" {
		t.Error("Mismatch database name")
	}
}
