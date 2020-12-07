package server

import (
	"Storyboard/backend/mocks"
	"testing"
)

func TestServerStartup(t *testing.T) {
	var taskRepoMock = &mocks.TaskRepoMock{}
	ss := NewRESTServer(taskRepoMock)
	ss.Start()
	ss.Stop()
}
