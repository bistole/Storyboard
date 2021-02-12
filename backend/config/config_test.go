package config

import (
	"os"
	"testing"
)

func TestConfig(t *testing.T) {
	config := NewConfigService("c:\\Storyboard")
	if config.GetHomeDir() != "c:\\Storyboard" {
		t.Error("Mismatch app name")
	}
	if config.GetDatabaseName() != "backend.db" {
		t.Error("Mismatch database name")
	}
}

func TestPanicForNotSetHomeDir(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Error("ConfigService did not panic as expected")
		}
	}()
	NewConfigService("")
}

func TestPropertyIP(t *testing.T) {
	dir, err := os.Getwd()
	if err != nil {
		t.Error("Failed to get pwd")
	}
	os.Remove(dir + "/backend.yaml")

	config := NewConfigService(dir)
	t.Log(config.props.toString())

	testIP := "192.168.7.123"
	testPort := 9999

	config.SetIP(testIP)
	if config.GetIP() != testIP {
		t.Error("IP is not set properly")
		t.Error(config.GetIP())
	}
	config.SetPort(testPort)
	if config.GetPort() != testPort {
		t.Error("Port is not set properly")
		t.Error(config.GetPort())
	}

	// loading again
	config.LoadFromConfigFile()
	if config.props.IP != testIP || config.props.PORT != testPort {
		t.Error("Failed to load saved config file")
	}

	os.Remove(dir + "/backend.yaml")
}
