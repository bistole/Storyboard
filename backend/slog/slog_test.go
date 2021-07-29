package slog

import (
	"bufio"
	"os"
	"path"
	"strings"
	"testing"
	"time"
)

func TestPrintBeforeSetPath(t *testing.T) {
	var rawLog = "println-after-set-path"

	Println(rawLog)
	if len(slog.buffer) == 0 || !strings.HasSuffix(slog.buffer[0], rawLog+"\n") {
		t.Error("No log in buffer")
	}

	folder := "./test-temporary-0"
	SetPath(folder)

	ts := time.Now().Format("2006-01-02")
	filename := path.Join(folder, "logs", "backend-"+ts+".log")
	_, err := os.Stat(filename)
	if err != nil {
		t.Error("Log file not exists")
	}

	f, err := os.Open(filename)
	if err != nil {
		t.Error("Failed to check log file")
	}

	scanner := bufio.NewScanner(f)
	var found = false
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasSuffix(line, rawLog) {
			found = true
		}
	}

	if !found {
		t.Error("Failed to find raw log in log file")
	}
	f.Close()

	os.RemoveAll(folder)
}

func TestPrintAfterSetPath(t *testing.T) {
	var rawLog = "println-before-set-path"

	folder := "./test-temporary-1"
	SetPath(folder)

	Printf(rawLog)
	if len(slog.buffer) != 0 {
		t.Error("Log found in buffer")
	}

	ts := time.Now().Format("2006-01-02")
	filename := path.Join(folder, "logs", "backend-"+ts+".log")
	_, err := os.Stat(filename)
	if err != nil {
		t.Error("Log file not exists")
	}

	f, err := os.Open(filename)
	if err != nil {
		t.Error("Failed to check log file")
	}

	scanner := bufio.NewScanner(f)
	var found = false
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasSuffix(line, rawLog) {
			found = true
		}
	}

	if !found {
		t.Error("Failed to find raw log in log file")
	}
	f.Close()

	os.RemoveAll(folder)
}
