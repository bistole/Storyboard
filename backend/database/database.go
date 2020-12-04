package database

import (
	"Storyboard/backend/config"
	"database/sql"
	"fmt"
	"os"
	"path"
	"time"

	"github.com/adrg/xdg"
	_ "github.com/mattn/go-sqlite3"
)

type dbWrapper struct {
	connDB *sql.DB
}

// DBWrapper is DB wrapper
var DBWrapper dbWrapper = dbWrapper{connDB: nil}

// ProcessError process if error raised
func (w dbWrapper) ProcessError(err error) {
	if err != nil {
		panic(err)
	}
}

// GetDB get DB connection
func (w dbWrapper) GetConnection() *sql.DB {
	if w.connDB != nil {
		return w.connDB
	}

	dirPath := w.GetDataFolder()
	fullPath := path.Join(dirPath, "foo.db")
	fmt.Printf("Create Database: %s\n", fullPath)
	_, err := os.Stat(fullPath)
	if os.IsNotExist(err) {
		os.MkdirAll(dirPath, 0755)
		os.Create(fullPath)
	}

	db, err := sql.Open("sqlite3", fullPath)
	w.ProcessError(err)

	w.connDB = db
	return db
}

// GetDataFolder get data folder
func (w dbWrapper) GetDataFolder() string {
	return path.Join(xdg.DataHome, config.VendorName, config.AppName)
}

// GetTS get transaction ID
func (w dbWrapper) GetTS() int64 {
	return time.Now().UnixNano()
}

// InitDatabase to init database
func (w dbWrapper) Init() bool {
	if w.connDB != nil {
		return true
	}

	db := w.GetConnection()
	// create table
	_, err := db.Exec("CREATE TABLE IF NOT EXISTS `tasks` (" +
		"`id` INTEGER PRIMARY KEY AUTOINCREMENT," +
		"`uuid` VARCHAR(36) NOT NULL UNIQUE," +
		"`title` TEXT NOT NULL," +
		"`deleted` INTEGER NOT NULL DEFAULT 0," +
		"`updatedAt` INTEGER NOT NULL," +
		"`createdAt` INTEGER NOT NULL," +
		"`_ts` INTEGER NOT NULL" +
		")")
	w.ProcessError(err)

	// create ts index
	_, err = db.Exec("CREATE INDEX IF NOT EXISTS `index_tasks_ts` " +
		" ON `tasks` ( `_ts` )")
	w.ProcessError(err)
	return true
}

// Close database connection
func (w dbWrapper) Close() {
	if w.connDB != nil {
		w.connDB.Close()
		w.connDB = nil
	}
}
