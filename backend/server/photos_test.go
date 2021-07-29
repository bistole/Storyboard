package server

import (
	"io"
	"io/ioutil"
	"storyboard/backend/mocks"
	"storyboard/backend/wrapper"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestGetPhotosSuccRequest(t *testing.T) {
	item := Photo{UUID: "uuid", Filename: "filename", Size: "100", Mime: "image/png", Direction: 180, UpdatedAt: 1000, CreatedAt: 2000, Deleted: 0}

	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	noteRepoMock := MockAllNoteError()
	photoRepoMock := MockAllPhotoError()
	photoRepoMock.GetPhotoMetaByTSFn = func(ts int64, limit, offset int) ([]mocks.Photo, error) {
		return []Photo{item}, nil
	}
	ss := NewRESTServer(netMock, httpMock, configMock, noteRepoMock, photoRepoMock)

	// create http request
	rr := GetRESTResponse(t, ss, ss.GetPhotos, "GET", "http://localhost:3000/photos", nil)

	expected := `{"succ":true,"photos":[{"uuid":"uuid","filename":"filename","size":"100","mime":"image/png","direction":180,"deleted":0,"createdAt":2000,"updatedAt":1000,"_ts":0}]}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestGetPhotoSuccRequest(t *testing.T) {
	item := Photo{UUID: "uuid", Filename: "filename", Size: "100", Mime: "image/png", Direction: 270, UpdatedAt: 1000, CreatedAt: 2000, Deleted: 0}

	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	noteRepoMock := MockAllNoteError()
	photoRepoMock := MockAllPhotoError()
	photoRepoMock.GetPhotoMetaFn = func(s string) (*mocks.Photo, error) {
		return &item, nil
	}
	ss := NewRESTServer(netMock, httpMock, configMock, noteRepoMock, photoRepoMock)

	// create http request
	rr := GetRESTResponse(t, ss, ss.GetPhoto, "GET", "http://localhost:3000/photos/uuid/meta", nil)

	expected := `{"succ":true,"photo":{"uuid":"uuid","filename":"filename","size":"100","mime":"image/png","direction":270,"deleted":0,"createdAt":2000,"updatedAt":1000,"_ts":0}}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestUploadPhotoSuccRequest(t *testing.T) {
	item := Photo{UUID: "uuid", Filename: "filename", Size: "100", Direction: 180, Mime: "image/png", UpdatedAt: 1000, CreatedAt: 2000, Deleted: 0}

	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	noteRepoMock := MockAllNoteError()
	photoRepoMock := MockAllPhotoError()
	photoRepoMock.AddPhotoFn = func(uuid, filename, size, mime string, direction int32, r io.Reader, createdAt int64) (*mocks.Photo, error) {
		t.Logf("%v, %v, %v, %v, %v, %v", uuid, filename, size, mime, direction, createdAt)
		return &item, nil
	}
	ss := NewRESTServer(netMock, httpMock, configMock, noteRepoMock, photoRepoMock)

	UUID := uuid.New().String()
	direction := strconv.Itoa(180)
	createdAt := strconv.Itoa(int(time.Now().Unix()))

	parts := map[string]RESTMultipartsDef{
		"uuid":      {isFile: false, val: UUID},
		"direction": {isFile: false, val: direction},
		"createdAt": {isFile: false, val: createdAt},
		"photo":     {isFile: true, path: "./photo_test.jpg", mime: "image/jpeg"},
	}

	rr := GetRESTMultipartResponse(t, ss, ss.UploadPhoto, "POST", "http://localhost:3000/photos/", parts)

	expected := `{"succ":true,"photo":{"uuid":"uuid","filename":"filename","size":"100","mime":"image/png","direction":180,"deleted":0,"createdAt":2000,"updatedAt":1000,"_ts":0}}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestDownloadPhotoSuccRequest(t *testing.T) {
	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	noteRepoMock := MockAllNoteError()
	photoRepoMock := MockAllPhotoError()
	photoRepoMock.GetPhotoFn = func(s string) (io.ReadCloser, error) {
		reader := strings.NewReader("hello photo")
		return ioutil.NopCloser(reader), nil
	}
	ss := NewRESTServer(netMock, httpMock, configMock, noteRepoMock, photoRepoMock)

	rr := GetRESTResponse(t, ss, ss.DownloadPhoto, "GET", "http://localhost:3000/photos/uuid", nil)

	expected := `hello photo`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestThumbnailPhotoSuccRequest(t *testing.T) {
	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	noteRepoMock := MockAllNoteError()
	photoRepoMock := MockAllPhotoError()
	photoRepoMock.GetPhotoThumbnailFn = func(s string) (io.ReadCloser, error) {
		reader := strings.NewReader("hello thumbnail")
		return ioutil.NopCloser(reader), nil
	}
	ss := NewRESTServer(netMock, httpMock, configMock, noteRepoMock, photoRepoMock)

	rr := GetRESTResponse(t, ss, ss.ThumbnailPhoto, "GET", "http://localhost:3000/photos/uuid/thumbnail", nil)

	expected := `hello thumbnail`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestUpdatePhotoRequest(t *testing.T) {
	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	noteRepoMock := MockAllNoteError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(netMock, httpMock, configMock, noteRepoMock, photoRepoMock)

	UUID := uuid.New().String()
	direction := strconv.FormatInt(180, 10)
	time := strconv.FormatInt(time.Now().Unix(), 10)
	body := strings.NewReader("{\"direction\": " + direction + ", \"updatedAt\": " + time + "}")

	// create http request
	rr := GetRESTResponse(t, ss, ss.UpdatePhoto, "POST", "http://localhost:3000/photos/"+UUID, body)

	expected := `{"succ":false,"Error":"Error to update photo"}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestDeletePhotoRequest(t *testing.T) {
	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	noteRepoMock := MockAllNoteError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(netMock, httpMock, configMock, noteRepoMock, photoRepoMock)

	// delete http request
	UUID := uuid.New().String()
	time := strconv.FormatInt(time.Now().Unix(), 10)
	body := strings.NewReader(`{"updatedAt": ` + time + `}`)

	// create http request
	rr := GetRESTResponse(t, ss, ss.DeletePhoto, "DELETE", "http://localhost:3000/photos/"+UUID, body)

	expected := `{"succ":false,"Error":"Error to delete photo"}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}
