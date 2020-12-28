package server

import (
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"storyboard/backend/mocks"
	"strconv"
	"strings"
	"testing"
	"time"

	uuid "github.com/google/uuid"
)

func MockAllTaskError() *mocks.TaskRepoMock {
	var taskRepoMock = &mocks.TaskRepoMock{
		CreateTaskFn: func(Task) (*Task, error) {
			return nil, fmt.Errorf("Error to create task")
		},
		UpdateTaskFn: func(string, Task) (*Task, error) {
			return nil, fmt.Errorf("Error to update task")
		},
		DeleteTaskFn: func(string) (*Task, error) {
			return nil, fmt.Errorf("Error to delete task")
		},
		GetTasksByTSFn: func(int64, int, int) ([]Task, error) {
			return nil, fmt.Errorf("Error to get list")
		},
		GetTaskByUUIDFn: func(string) (*Task, error) {
			return nil, fmt.Errorf("Error to get task")
		},
	}
	return taskRepoMock
}

func MockAllPhotoError() *mocks.PhotoRepoMock {
	var photoRepoMock = &mocks.PhotoRepoMock{
		AddPhotoFn: func(uuid, filename, mime, size string, i io.Reader, ud int64) (*mocks.Photo, error) {
			return nil, fmt.Errorf("Error to add photo")
		},
		DeletePhotoFn: func(s string) (*mocks.Photo, error) {
			return nil, fmt.Errorf("Error to delete photo")
		},
		GetPhotoFn: func(s string) (io.ReadCloser, error) {
			return nil, fmt.Errorf("Error to get photo")
		},
		GetPhotoThumbnailFn: func(s string) (io.ReadCloser, error) {
			return nil, fmt.Errorf("Error to get photo thumbnail")
		},
		GetPhotoMetaFn: func(s string) (*mocks.Photo, error) {
			return nil, fmt.Errorf("Error to get photo meta data")
		},
		GetPhotoMetaByTSFn: func(ts int64, limit, offset int) ([]mocks.Photo, error) {
			return nil, fmt.Errorf("Error to get list")
		},
	}
	return photoRepoMock
}

func TestGetTasksRequests(t *testing.T) {
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	// create http request
	req, err := http.NewRequest("GET", "http://localhost:3000/tasks", nil)
	if err != nil {
		t.Fatal("Can not make a get-list request")
	}
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(ss.GetTasks)

	// send request
	handler.ServeHTTP(rr, req)

	// get result
	if status := rr.Result().StatusCode; status != http.StatusOK {
		t.Errorf("Wrong response status code: got %v want %v", status, http.StatusOK)
	}

	expected := `{"succ":false,"Error":"Error to get list"}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestCreateTasksRequests(t *testing.T) {
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	// create http request
	UUID := uuid.New().String()
	time := strconv.FormatInt(time.Now().Unix(), 10)
	body := strings.NewReader(`{"UUID": "` + UUID + `", "title": "second options", "createdAt": ` + time + `}`)
	req, err := http.NewRequest("POST", "http://localhost:3000/tasks", body)
	if err != nil {
		t.Fatal("Can not make a create request")
	}
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(ss.CreateTask)

	// send request
	handler.ServeHTTP(rr, req)

	// get result
	if status := rr.Result().StatusCode; status != http.StatusOK {
		t.Errorf("Wrong response status code: got %v want %v", status, http.StatusOK)
	}

	expected := `{"succ":false,"Error":"Error to create task"}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}
