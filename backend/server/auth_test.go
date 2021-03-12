package server

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"storyboard/backend/mocks"
	"storyboard/backend/wrapper"
	"strings"
	"testing"
	"time"

	"github.com/gorilla/mux"
)

type CloseNotifyingRecorder struct {
	*httptest.ResponseRecorder
	closed chan bool
}

func newCloseNotifyingRecorder() *CloseNotifyingRecorder {
	return &CloseNotifyingRecorder{
		httptest.NewRecorder(),
		make(chan bool, 1),
	}
}

func (c *CloseNotifyingRecorder) close() {
	c.closed <- true
}

func (c *CloseNotifyingRecorder) CloseNotify() <-chan bool {
	return c.closed
}

func GetRESTCloseNotifyingResponse(t *testing.T, ss *RESTServer, f httpFunc,
	method string, url string, body io.Reader) *CloseNotifyingRecorder {

	req, err := http.NewRequest(method, url, body)
	req.Header.Add("Client-ID", "client-abc")

	if err != nil {
		t.Fatal("Can not make a request")
	}
	rr := newCloseNotifyingRecorder()
	handler := http.HandlerFunc(f)

	// send request
	handler.ServeHTTP(rr, req)

	// get result
	if status := rr.Result().StatusCode; status != http.StatusOK {
		t.Errorf("Wrong response status code: got %v want %v", status, http.StatusOK)
	}
	return rr
}

// SSEResponseBlock to test response of sse server
type SSEResponseBlock struct {
	Action string            `json:"action"`
	Params map[string]string `json:"params"`
	TS     int               `json:"ts"`
}

func TestSSESever(t *testing.T) {
	configMock := &mocks.ConfigMock{}
	netMock := MockNetProxy()
	httpMock := wrapper.NewHTTPWrapper()
	taskRepoMock := MockAllTaskError()
	photoRepoMock := MockAllPhotoError()
	ss := NewRESTServer(netMock, httpMock, configMock, taskRepoMock, photoRepoMock)

	// install sse server
	ss.EventServer = *createEventServer()
	route := mux.NewRouter()
	ss.EventServer.route(route)
	go ss.EventServer.MainLoop()
	go ss.EventServer.KeepAlive()

	go func() {
		time.Sleep(time.Second * 1)
		ss.EventServer.End()
	}()

	rr := GetRESTCloseNotifyingResponse(t, ss, ss.EventServer.Handler, "GET", "http://localhost:3000/events", nil)
	t.Log(rr.Body.String())

	bodyArr := strings.Fields(rr.Body.String())
	if len(bodyArr) < 2 || len(bodyArr) > 3 {
		t.Error("Did not receive welcome & close response")
	}

	var block0 SSEResponseBlock
	json.Unmarshal([]byte(bodyArr[0]), &block0)
	if block0.Action != "welcome" {
		t.Error("Did not receive welcome package")
	}

	var blocklast SSEResponseBlock
	json.Unmarshal([]byte(bodyArr[len(bodyArr)-1]), &blocklast)
	if blocklast.Action != "close" {
		t.Error("Did not receive close package")
	}
}
