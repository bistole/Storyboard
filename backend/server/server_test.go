package server

import (
	"storyboard/backend/mocks"
	"testing"
)

func TestServerStartup(t *testing.T) {
	var taskRepoMock = &mocks.TaskRepoMock{}
	var photoRepoMock = &mocks.PhotoRepoMock{}
	ss := NewRESTServer(taskRepoMock, photoRepoMock)
	ss.Start()
	ss.Stop()
}
