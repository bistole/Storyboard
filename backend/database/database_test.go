package database

import (
	"storyboard/backend/mocks"

	"os"
	"path"
	"testing"

	"github.com/adrg/xdg"
)

// TestDatabase test database function
func TestDatabase(t *testing.T) {
	const testFolder = "TestFolder_dev"
	const testVendor = "Laterhorse_dev"
	const testDB = "foo_dev.db"
	dbPath := path.Join(xdg.DataHome, testVendor, testFolder, testDB)
	os.Remove(dbPath)

	var cftMock = &mocks.ConfigMock{
		GetHomeDirFn: func() string {
			return path.Join(xdg.DataHome, testVendor, testFolder)
		},
		GetDatabaseNameFn: func() string {
			return testDB
		},
	}

	var db = NewDatabaseService(cftMock)
	db.Init()

	if db.GetConnection() == nil {
		t.Errorf("db conn is not created")
		return
	}

	_, err := db.connDB.Exec("SELECT 1")
	if err != nil {
		t.Error(err)
		return
	}

	db.Close()
}
