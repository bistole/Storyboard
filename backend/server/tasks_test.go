package server

import (
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"net/textproto"
	"os"
	"storyboard/backend/mocks"
	"storyboard/backend/wrapper"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
)

type httpFunc func(http.ResponseWriter, *http.Request)

func GetRESTResponse(t *testing.T, ss *RESTServer, f httpFunc,
	method string, url string, body io.Reader) *httptest.ResponseRecorder {
	req, err := http.NewRequest(method, url, body)
	req.Header.Add("Client-ID", "client-abc")

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

type RESTMultipartsDef struct {
	isFile bool
	val    string
	path   string
	mime   string
}

var quoteEscaper = strings.NewReplacer("\\", "\\\\", `"`, "\\\"")

func escapeQuotes(s string) string {
	return quoteEscaper.Replace(s)
}

func GetRESTMultipartResponse(t *testing.T, ss *RESTServer, f httpFunc,
	method string, url string, parts map[string]RESTMultipartsDef) *httptest.ResponseRecorder {

	body, writer := io.Pipe()
	req, err := http.NewRequest(method, url, body)
	req.Header.Add("Client-ID", "client-abc")
	if err != nil {
		t.Fatalf("Can not make a request\n")
	}
	multiWriter := multipart.NewWriter(writer)
	req.Header.Add("Content-Type", multiWriter.FormDataContentType())

	errchan := make(chan error)
	go func() {
		defer close(errchan)
		defer writer.Close()
		defer multiWriter.Close()

		for key, val := range parts {
			var w io.Writer
			var r io.Reader
			if val.isFile {
				fi, err := os.Stat(val.path)
				if err != nil {
					errchan <- err
					return
				}
				len := int(fi.Size())

				r, err = os.Open(val.path)
				if err != nil {
					errchan <- err
					return
				}

				h := make(textproto.MIMEHeader)
				h.Set("Content-Disposition",
					fmt.Sprintf(`form-data; name="%s"; filename="%s"`,
						escapeQuotes(key), escapeQuotes(val.path)))
				h.Set("Content-Type", val.mime)
				h.Set("Content-Length", strconv.Itoa(len))
				w, err = multiWriter.CreatePart(h)
			} else {
				r = strings.NewReader(val.val)
				w, err = multiWriter.CreateFormField(key)
			}
			if err != nil {
				errchan <- err
				return
			}

			if _, err = io.Copy(w, r); err != nil {
				errchan <- err
				return
			}
		}
	}()

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(ss.UploadPhoto)

	// send request
	handler.ServeHTTP(rr, req)

	// get result
	if status := rr.Result().StatusCode; status != http.StatusOK {
		t.Errorf("Wrong response status code: got %v want %v", status, http.StatusOK)
	}

	multiErr := <-errchan
	if multiErr != nil {
		t.Errorf("Wrong multipart error: %v", multiErr)
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
		AddPhotoFn: func(uuid, filename, mime, size string, direction int32, i io.Reader, ud int64) (*mocks.Photo, error) {
			return nil, fmt.Errorf("Error to add photo")
		},
		UpdatePhotoFn: func(uuid string, photo mocks.Photo) (*mocks.Photo, error) {
			return nil, fmt.Errorf("Error to update photo")
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

func TestGetTasksSuccRequest(t *testing.T) {
	item := Task{UUID: "uuid", Title: "title", UpdatedAt: 1000, CreatedAt: 2000, Deleted: 0}

	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	taskRepoMock := MockAllTaskError()
	taskRepoMock.GetTasksByTSFn = func(ts int64, limit, offset int) ([]mocks.Task, error) {
		return []Task{item}, nil
	}
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(netMock, httpMock, configMock, taskRepoMock, photoRepoMock)

	// create http request
	rr := GetRESTResponse(t, ss, ss.GetTasks, "GET", "http://localhost:3000/tasks", nil)

	expected := `{"succ":true,"tasks":[{"uuid":"uuid","title":"title","deleted":0,"createdAt":2000,"updatedAt":1000,"_ts":0}]}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestGetTasksFailureRequest(t *testing.T) {
	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(netMock, httpMock, configMock, taskRepoMock, photoRepoMock)

	// create http request
	rr := GetRESTResponse(t, ss, ss.GetTasks, "GET", "http://localhost:3000/tasks", nil)

	expected := `{"succ":false,"Error":"Error to get list"}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestGetTaskSuccRequest(t *testing.T) {
	item := Task{UUID: "uuid", Title: "title", UpdatedAt: 1000, CreatedAt: 2000, Deleted: 0}

	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	taskRepoMock := MockAllTaskError()
	taskRepoMock.GetTaskByUUIDFn = func(s string) (*mocks.Task, error) {
		return &item, nil
	}
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(netMock, httpMock, configMock, taskRepoMock, photoRepoMock)

	// create http request
	rr := GetRESTResponse(t, ss, ss.GetTask, "GET", "http://localhost:3000/tasks/uuid", nil)

	expected := `{"succ":true,"task":{"uuid":"uuid","title":"title","deleted":0,"createdAt":2000,"updatedAt":1000,"_ts":0}}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestGetTaskFailureRequest(t *testing.T) {
	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(netMock, httpMock, configMock, taskRepoMock, photoRepoMock)

	// create http request
	rr := GetRESTResponse(t, ss, ss.GetTask, "GET", "http://localhost:3000/tasks/uuid", nil)

	expected := `{"succ":false,"Error":"Error to get task"}`
	if expected != strings.Trim(rr.Body.String(), "\n") {
		t.Errorf("Unexpected respones: got %s want %s", rr.Body.String(), expected)
	}
}

func TestCreateTaskRequest(t *testing.T) {
	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(netMock, httpMock, configMock, taskRepoMock, photoRepoMock)

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

func TestUpdateTaskRequest(t *testing.T) {
	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(netMock, httpMock, configMock, taskRepoMock, photoRepoMock)

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

func TestDeleteTaskRequest(t *testing.T) {
	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(netMock, httpMock, configMock, taskRepoMock, photoRepoMock)

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
