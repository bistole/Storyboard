package server

import (
	"storyboard/backend/mocks"
	"testing"
)

func TestServerStartup(t *testing.T) {
	var configMock = &mocks.ConfigMock{}
	var taskRepoMock = &mocks.TaskRepoMock{}
	var photoRepoMock = &mocks.PhotoRepoMock{}
	ss := NewRESTServer(configMock, taskRepoMock, photoRepoMock)
	ss.Start()
	ss.Stop()
}
