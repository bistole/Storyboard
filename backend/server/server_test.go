package server

import (
	"storyboard/backend/mocks"
	"testing"
)

func TestServerStartup(t *testing.T) {
	var taskRepoMock = &mocks.TaskRepoMock{}
	ss := NewRESTServer(taskRepoMock)
	ss.Start()
	ss.Stop()
}
