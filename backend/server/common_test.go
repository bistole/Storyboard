package server

import (
	"net/http"
	"net/url"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

// TODO: test GetServerIPs

func TestConvertQueryParamToIntDefault(t *testing.T) {
	url, _ := url.Parse("http://localhost:3000/notes")
	req := http.Request{URL: url}
	key := ConvertQueryParamToInt(&req, "key", 100)
	assert.Equal(t, key, 100)
}

func TestConvertQueryParamToIntValue(t *testing.T) {
	url, _ := url.Parse("http://localhost:3000/notes?key=999")
	req := http.Request{URL: url}
	key := ConvertQueryParamToInt(&req, "key", 100)
	assert.Equal(t, key, 999)
}

func TestIsStringUUID(t *testing.T) {
	assert.EqualError(t, IsStringUUID("uuid", "invalid"), "invalid")
	assert.Nil(t, IsStringUUID("5154b54e-bb6a-4d22-ad99-dc33778e9e65", "invalid"))
}

func TestIsStringNotEmpty(t *testing.T) {
	assert.EqualError(t, IsStringNotEmpty("", "empty"), "empty")
	assert.Nil(t, IsStringNotEmpty("not empty", "empty"))
}

func TestIsIntValidDate(t *testing.T) {
	assert.EqualError(t, IsIntValidDate(0, "invalid"), "invalid")

	ts := time.Now().Unix()
	assert.Nil(t, IsIntValidDate(ts, "invalid"))
}
