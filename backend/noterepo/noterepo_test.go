package noterepo

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
const testDBName = "foo_note_"

// TODO: test error cases

func initDB(suffix string) interfaces.DatabaseService {
	conf := &mocks.ConfigMock{
		GetHomeDirFn: func() string {
			return "C:\\" + testAppName + suffix
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

func _testCreate(t *testing.T, noteRepo NoteRepo) *Note {
	createdAt := time.Now().Unix() - 1000
	updatedAt := time.Now().Unix()

	// create
	inNote := Note{
		UUID:      uuid.New().String(),
		Title:     "new title",
		CreatedAt: createdAt,
		UpdatedAt: updatedAt,
	}
	createdNote, err := noteRepo.CreateNote(inNote)
	if err != nil {
		t.Errorf("Failed to create note: %v", err)
	}

	nownano := time.Now().UnixNano()

	assert.Equal(t, inNote.UUID, createdNote.UUID)
	assert.Equal(t, "new title", createdNote.Title)
	assert.Equal(t, createdNote.Deleted, int8(0))
	assert.Equal(t, createdNote.CreatedAt, createdAt)
	assert.Equal(t, createdNote.UpdatedAt, updatedAt)
	assert.Less(t, nownano-2000000000, createdNote.TS)
	assert.Greater(t, nownano+2000000000, createdNote.TS)

	return createdNote
}

func _testUpdate(t *testing.T, noteRepo NoteRepo, createdNote *Note) *Note {
	UUID := createdNote.UUID
	updatedAt := time.Now().Unix()

	inNote := Note{Title: "update title", UpdatedAt: updatedAt}
	updatedNote, err := noteRepo.UpdateNote(UUID, inNote)
	if err != nil {
		t.Errorf("Failed to update note: %v", err)
	}

	assert.Equal(t, "update title", updatedNote.Title)
	assert.Equal(t, updatedNote.UUID, UUID)
	assert.Equal(t, updatedNote.Deleted, int8(0))
	assert.Equal(t, updatedNote.UpdatedAt, updatedAt)
	assert.Equal(t, createdNote.CreatedAt, updatedNote.CreatedAt)
	assert.Greater(t, updatedNote.TS, createdNote.TS)

	return updatedNote
}

func _testDelete(t *testing.T, noteRepo NoteRepo, updatedNote *Note) *Note {
	updatedAt := time.Now().Unix()
	deletedNote, err := noteRepo.DeleteNote(updatedNote.UUID, updatedAt)
	if err != nil {
		t.Errorf("Failed to delete note: %v", err)
	}

	assert.Equal(t, "update title", deletedNote.Title)
	assert.Equal(t, deletedNote.UUID, updatedNote.UUID)
	assert.Equal(t, deletedNote.Deleted, int8(1))
	assert.Equal(t, deletedNote.CreatedAt, updatedNote.CreatedAt)
	assert.Greater(t, deletedNote.TS, updatedNote.TS)
	assert.Greater(t, deletedNote.UpdatedAt, updatedNote.UpdatedAt)

	return deletedNote
}

func _testGet(t *testing.T, noteRepo NoteRepo, deletedNode *Note) {
	getNote, err := noteRepo.GetNoteByUUID(deletedNode.UUID)
	if err != nil {
		t.Errorf("Failed to get note: %v", err)
	}

	assert.Equal(t, getNote.UUID, deletedNode.UUID)
	assert.Equal(t, getNote.CreatedAt, deletedNode.CreatedAt)
	assert.Equal(t, getNote.UpdatedAt, deletedNode.UpdatedAt)
	assert.Equal(t, getNote.TS, deletedNode.TS)
}

func _testList(t *testing.T, noteRepo NoteRepo, deletedNote *Note) {
	notes, err := noteRepo.GetNotesByTS(0, 10, 0)
	if err != nil {
		t.Errorf("Failed to get notes: %v", err)
	}

	assert.Equal(t, len(notes), 1)
	assert.Equal(t, notes[0].UUID, deletedNote.UUID)
	assert.Equal(t, notes[0].CreatedAt, deletedNote.CreatedAt)
	assert.Equal(t, notes[0].UpdatedAt, deletedNote.UpdatedAt)
	assert.Equal(t, notes[0].TS, deletedNote.TS)
}

func TestNoteRepo(t *testing.T) {
	db := initDB("test")
	defer destoyDB("test", db)

	noteRepo := NewNoteRepo(db)

	createdNote := _testCreate(t, noteRepo)

	// sleep
	time.Sleep(time.Second * 1)

	// update
	updatedNote := _testUpdate(t, noteRepo, createdNote)

	// sleep
	time.Sleep(time.Second * 1)

	// delete
	deletedNote := _testDelete(t, noteRepo, updatedNote)

	// get note by uuid
	_testGet(t, noteRepo, deletedNote)

	// get note list
	_testList(t, noteRepo, deletedNote)
}
