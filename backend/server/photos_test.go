package server

import (
	"io"
	"io/ioutil"
	"storyboard/backend/mocks"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestGetPhotosSuccRequest(t *testing.T) {
	item := Photo{UUID: "uuid", Filename: "filename", Size: "100", Mime: "image/png", UpdatedAt: 1000, CreatedAt: 2000, Deleted: 0}

	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	photoRepoMock.GetPhotoMetaByTSFn = func(ts int64, limit, offset int) ([]mocks.Photo, error) {
		return []Photo{item}, nil
	}
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	// create http request
	rr := GetRESTResponse(t, ss, ss.GetPhotos, "GET", "http://localhost:3000/photos", nil)

	expected := `{"succ":true,"photos":[{"uuid":"uuid","filename":"filename","size":"100","mime":"image/png","deleted":0,"createdAt":2000,"updatedAt":1000,"_ts":0}]}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestGetPhotoSuccRequest(t *testing.T) {
	item := Photo{UUID: "uuid", Filename: "filename", Size: "100", Mime: "image/png", UpdatedAt: 1000, CreatedAt: 2000, Deleted: 0}

	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	photoRepoMock.GetPhotoMetaFn = func(s string) (*mocks.Photo, error) {
		return &item, nil
	}
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	// create http request
	rr := GetRESTResponse(t, ss, ss.GetPhoto, "GET", "http://localhost:3000/photos/uuid/meta", nil)

	expected := `{"succ":true,"photo":{"uuid":"uuid","filename":"filename","size":"100","mime":"image/png","deleted":0,"createdAt":2000,"updatedAt":1000,"_ts":0}}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestUploadPhotoSuccRequest(t *testing.T) {
	item := Photo{UUID: "uuid", Filename: "filename", Size: "100", Mime: "image/png", UpdatedAt: 1000, CreatedAt: 2000, Deleted: 0}

	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	photoRepoMock.AddPhotoFn = func(uuid, filename, size, mime string, r io.Reader, createdAt int64) (*mocks.Photo, error) {
		t.Logf("%v, %v, %v, %v, %v", uuid, filename, size, mime, createdAt)
		return &item, nil
	}
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	UUID := uuid.New().String()
	createdAt := strconv.Itoa(int(time.Now().Unix()))

	parts := map[string]RESTMultipartsDef{
		"uuid":      {isFile: false, val: UUID},
		"createdAt": {isFile: false, val: createdAt},
		"photo":     {isFile: true, path: "./photo_test.jpg", mime: "image/jpeg"},
	}

	rr := GetRESTMultipartResponse(t, ss, ss.UploadPhoto, "POST", "http://localhost:3000/photos/", parts)

	expected := `{"succ":true,"photo":{"uuid":"uuid","filename":"filename","size":"100","mime":"image/png","deleted":0,"createdAt":2000,"updatedAt":1000,"_ts":0}}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestDownloadPhotoSuccRequest(t *testing.T) {
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	photoRepoMock.GetPhotoFn = func(s string) (io.ReadCloser, error) {
		reader := strings.NewReader("hello photo")
		return ioutil.NopCloser(reader), nil
	}
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	rr := GetRESTResponse(t, ss, ss.DownloadPhoto, "GET", "http://localhost:3000/photos/uuid", nil)

	expected := `hello photo`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestThumbnailPhotoSuccRequest(t *testing.T) {
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	photoRepoMock.GetPhotoThumbnailFn = func(s string) (io.ReadCloser, error) {
		reader := strings.NewReader("hello thumbnail")
		return ioutil.NopCloser(reader), nil
	}
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	rr := GetRESTResponse(t, ss, ss.ThumbnailPhoto, "GET", "http://localhost:3000/photos/uuid/thumbnail", nil)

	expected := `hello thumbnail`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestDeletePhotoRequest(t *testing.T) {
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

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
