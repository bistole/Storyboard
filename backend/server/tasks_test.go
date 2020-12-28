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

type httpFunc func(http.ResponseWriter, *http.Request)

func GetRESTResponse(t *testing.T, ss *RESTServer, f httpFunc,
	method string, url string, body io.Reader) *httptest.ResponseRecorder {
	req, err := http.NewRequest(method, url, body)
	if err != nil {
		t.Fatal("Can not make a request")
	}
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(f)

	// send request
	handler.ServeHTTP(rr, req)

	// get result
	if status := rr.Result().StatusCode; status != http.StatusOK {
		t.Errorf("Wrong response status code: got %v want %v", status, http.StatusOK)
	}

	return rr
}

func MockAllTaskError() *mocks.TaskRepoMock {
	var taskRepoMock = &mocks.TaskRepoMock{
		CreateTaskFn: func(Task) (*Task, error) {
			return nil, fmt.Errorf("Error to create task")
		},
		UpdateTaskFn: func(string, Task) (*Task, error) {
			return nil, fmt.Errorf("Error to update task")
		},
		DeleteTaskFn: func(string, int64) (*Task, error) {
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
		DeletePhotoFn: func(s string, ud int64) (*mocks.Photo, error) {
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

func TestGetTasksSuccRequests(t *testing.T) {
	item := Task{UUID: "uuid", Title: "title", UpdatedAt: 1000, CreatedAt: 2000, Deleted: 0}

	taskRepoMock := MockAllTaskError()
	taskRepoMock.GetTasksByTSFn = func(ts int64, limit, offset int) ([]mocks.Task, error) {
		return []Task{item}, nil
	}
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	// create http request
	rr := GetRESTResponse(t, ss, ss.GetTasks, "GET", "http://localhost:3000/tasks", nil)

	expected := `{"succ":true,"tasks":[{"uuid":"uuid","title":"title","deleted":0,"createdAt":2000,"updatedAt":1000,"_ts":0}]}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestGetTasksFailureRequests(t *testing.T) {
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	// create http request
	rr := GetRESTResponse(t, ss, ss.GetTasks, "GET", "http://localhost:3000/tasks", nil)

	expected := `{"succ":false,"Error":"Error to get list"}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestGetTaskSuccRequest(t *testing.T) {
	item := Task{UUID: "uuid", Title: "title", UpdatedAt: 1000, CreatedAt: 2000, Deleted: 0}

	taskRepoMock := MockAllTaskError()
	taskRepoMock.GetTaskByUUIDFn = func(s string) (*mocks.Task, error) {
		return &item, nil
	}
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	// create http request
	rr := GetRESTResponse(t, ss, ss.GetTask, "GET", "http://localhost:3000/tasks/uuid", nil)

	expected := `{"succ":true,"task":{"uuid":"uuid","title":"title","deleted":0,"createdAt":2000,"updatedAt":1000,"_ts":0}}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestGetTaskFailureRequest(t *testing.T) {
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	// create http request
	rr := GetRESTResponse(t, ss, ss.GetTask, "GET", "http://localhost:3000/tasks/uuid", nil)

	expected := `{"succ":false,"Error":"Error to get task"}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestCreateTaskRequests(t *testing.T) {
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	// create http request
	UUID := uuid.New().String()
	time := strconv.FormatInt(time.Now().Unix(), 10)
	body := strings.NewReader(`{"UUID": "` + UUID + `", "title": "second options", "createdAt": ` + time + `}`)

	// create http request
	rr := GetRESTResponse(t, ss, ss.CreateTask, "POST", "http://localhost:3000/tasks", body)

	expected := `{"succ":false,"Error":"Error to create task"}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestUpdateTasksRequests(t *testing.T) {
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	UUID := uuid.New().String()
	time := strconv.FormatInt(time.Now().Unix(), 10)
	body := strings.NewReader(`{"title": "changed options", "updatedAt": ` + time + `}`)

	// create http request
	rr := GetRESTResponse(t, ss, ss.UpdateTask, "POST", "http://localhost:3000/tasks/"+UUID, body)

	expected := `{"succ":false,"Error":"Error to update task"}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestDeleteTasksRequests(t *testing.T) {
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(taskRepoMock, photoRepoMock)

	// delete http request
	UUID := uuid.New().String()
	time := strconv.FormatInt(time.Now().Unix(), 10)
	body := strings.NewReader(`{"updatedAt": ` + time + `}`)

	// create http request
	rr := GetRESTResponse(t, ss, ss.DeleteTask, "DELETE", "http://localhost:3000/tasks/"+UUID, body)

	expected := `{"succ":false,"Error":"Error to delete task"}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}
