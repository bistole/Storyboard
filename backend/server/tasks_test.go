package server

import (
	"Storyboard/backend/mocks"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func MockAllError() *mocks.TaskRepoMock {
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

func TestGetTasksRequests(t *testing.T) {
	taskRepoMock := MockAllError()
	ss := NewRESTServer(taskRepoMock)

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
	taskRepoMock := MockAllError()
	ss := NewRESTServer(taskRepoMock)

	// create http request
	body := strings.NewReader(`{"title": "second options"}`)
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
