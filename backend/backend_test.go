package backend

import "testing"

func TestStart(t *testing.T) {
	want := "Hello, World"
	if got := Start(); got != want {
		t.Errorf("Hello() != %q, want %q", got, want)
	}
}
