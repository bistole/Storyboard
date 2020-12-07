package taskrepo

import (
	"Storyboard/backend/database"
	"Storyboard/backend/interfaces"
	"Storyboard/backend/mocks"
	"time"

	"os"
	"path"
	"testing"

	"github.com/stretchr/testify/assert"
)

const testVendorName = "Laterhorse_"
const testAppName = "Storyboard_"
const testDBName = "foo_"

func initDB(suffix string) interfaces.DatabaseService {
	conf := &mocks.ConfigMock{
		GetVendorNameFn: func() string {
			return testVendorName + suffix
		},
		GetAppNameFn: func() string {
			return testAppName + suffix
		},
		GetDatabaseNameFn: func() string {
			return testDBName + suffix + ".db"
		},
	}
	db := database.NewDatabaseService(conf)
	db.Init()
	return db
}

func destoyDB(suffix string, db interfaces.DatabaseService) {
	db.Close()

	folder := db.GetDataFolder()
	os.Remove(path.Join(folder, testDBName+suffix+".db"))
	os.Remove(folder)
}

func TestCreateTask(t *testing.T) {
	db := initDB("test")

	taskRepo := NewTaskRepo(db)

	// create
	inTask := Task{Title: "new title"}
	createdTask, err := taskRepo.CreateTask(inTask)
	if err != nil {
		t.Errorf("Failed to create task: %v", err)
	}

	now := time.Now().Unix()
	nownano := time.Now().UnixNano()

	assert.Equal(t, "new title", createdTask.Title)
	assert.NotEmpty(t, createdTask.UUID)
	assert.Equal(t, createdTask.Deleted, int8(0))
	assert.Less(t, nownano-2000000000, createdTask.TS)
	assert.Greater(t, nownano+2000000000, createdTask.TS)
	assert.Less(t, now-2, createdTask.UpdatedAt)
	assert.Greater(t, now+2, createdTask.UpdatedAt)
	assert.Less(t, now-2, createdTask.CreatedAt)
	assert.Greater(t, now+2, createdTask.CreatedAt)

	// sleep
	time.Sleep(time.Second * 1)

	// update
	UUID := createdTask.UUID
	inTask = Task{Title: "update title"}
	updatedTask, err := taskRepo.UpdateTask(UUID, inTask)
	if err != nil {
		t.Errorf("Failed to update task: %v", err)
	}

	assert.Equal(t, "update title", updatedTask.Title)
	assert.Equal(t, updatedTask.UUID, UUID)
	assert.Equal(t, updatedTask.Deleted, int8(0))
	assert.Equal(t, createdTask.CreatedAt, updatedTask.CreatedAt)
	assert.Greater(t, updatedTask.TS, createdTask.TS)
	assert.Greater(t, updatedTask.UpdatedAt, createdTask.UpdatedAt)

	// sleep
	time.Sleep(time.Second * 1)

	// delete
	deletedTask, err := taskRepo.DeleteTask(UUID)
	if err != nil {
		t.Errorf("Failed to delete task: %v", err)
	}

	assert.Equal(t, "update title", deletedTask.Title)
	assert.Equal(t, deletedTask.UUID, UUID)
	assert.Equal(t, deletedTask.Deleted, int8(1))
	assert.Equal(t, deletedTask.CreatedAt, updatedTask.CreatedAt)
	assert.Greater(t, deletedTask.TS, updatedTask.TS)
	assert.Greater(t, deletedTask.UpdatedAt, updatedTask.UpdatedAt)

	destoyDB("test", db)
}
