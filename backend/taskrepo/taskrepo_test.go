package taskrepo

import (
	"storyboard/backend/database"
	"storyboard/backend/interfaces"
	"storyboard/backend/mocks"
	"time"

	"os"
	"path"
	"testing"

	"github.com/google/uuid"
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

	createdAt := time.Now().Unix() - 1000
	updatedAt := time.Now().Unix()

	// create
	inTask := Task{
		UUID:      uuid.New().String(),
		Title:     "new title",
		CreatedAt: createdAt,
		UpdatedAt: updatedAt,
	}
	createdTask, err := taskRepo.CreateTask(inTask)
	if err != nil {
		t.Errorf("Failed to create task: %v", err)
	}

	nownano := time.Now().UnixNano()

	assert.Equal(t, inTask.UUID, createdTask.UUID)
	assert.Equal(t, "new title", createdTask.Title)
	assert.Equal(t, createdTask.Deleted, int8(0))
	assert.Equal(t, createdTask.CreatedAt, createdAt)
	assert.Equal(t, createdTask.UpdatedAt, updatedAt)
	assert.Less(t, nownano-2000000000, createdTask.TS)
	assert.Greater(t, nownano+2000000000, createdTask.TS)

	// sleep
	time.Sleep(time.Second * 1)

	// update
	UUID := createdTask.UUID
	updatedAt = time.Now().Unix()
	inTask = Task{Title: "update title", UpdatedAt: updatedAt}
	updatedTask, err := taskRepo.UpdateTask(UUID, inTask)
	if err != nil {
		t.Errorf("Failed to update task: %v", err)
	}

	assert.Equal(t, "update title", updatedTask.Title)
	assert.Equal(t, updatedTask.UUID, UUID)
	assert.Equal(t, updatedTask.Deleted, int8(0))
	assert.Equal(t, updatedTask.UpdatedAt, updatedAt)
	assert.Equal(t, createdTask.CreatedAt, updatedTask.CreatedAt)
	assert.Greater(t, updatedTask.TS, createdTask.TS)

	// sleep
	time.Sleep(time.Second * 1)

	// delete
	updatedAt = time.Now().Unix()
	deletedTask, err := taskRepo.DeleteTask(UUID, updatedAt)
	if err != nil {
		t.Errorf("Failed to delete task: %v", err)
	}

	assert.Equal(t, "update title", deletedTask.Title)
	assert.Equal(t, deletedTask.UUID, UUID)
	assert.Equal(t, deletedTask.Deleted, int8(1))
	assert.Equal(t, deletedTask.CreatedAt, updatedTask.CreatedAt)
	assert.Greater(t, deletedTask.TS, updatedTask.TS)
	assert.Greater(t, deletedTask.UpdatedAt, updatedTask.UpdatedAt)

	// get task by uuid
	getTask, err := taskRepo.GetTaskByUUID(UUID)
	if err != nil {
		t.Errorf("Failed to get task: %v", err)
	}

	assert.Equal(t, getTask.UUID, UUID)
	assert.Equal(t, getTask.CreatedAt, deletedTask.CreatedAt)
	assert.Equal(t, getTask.UpdatedAt, deletedTask.UpdatedAt)
	assert.Equal(t, getTask.TS, deletedTask.TS)

	// get tasks
	tasks, err := taskRepo.GetTasksByTS(0, 10, 0)
	if err != nil {
		t.Errorf("Failed to get tasks: %v", err)
	}

	assert.Equal(t, len(tasks), 1)
	assert.Equal(t, tasks[0].UUID, UUID)
	assert.Equal(t, tasks[0].CreatedAt, deletedTask.CreatedAt)
	assert.Equal(t, tasks[0].UpdatedAt, deletedTask.UpdatedAt)
	assert.Equal(t, tasks[0].TS, deletedTask.TS)

	destoyDB("test", db)
}
