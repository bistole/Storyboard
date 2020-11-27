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

var connDB *sql.DB = nil

// GetDB get DB connection
func GetDB() *sql.DB {
	return connDB
}

// ProcessError process if error raised
func ProcessError(err error) {
	if err != nil {
		panic(err)
	}
}

// GetDataFolder get data folder
func GetDataFolder() string {
	return path.Join(xdg.DataHome, config.VendorName, config.AppName)
}

// GetTS get transaction ID
func GetTS() int64 {
	return time.Now().UnixNano()
}

// InitDatabase to init database
func InitDatabase() bool {
	if connDB != nil {
		return true
	}

	dirPath := GetDataFolder()
	fullPath := path.Join(dirPath, "foo.db")
	fmt.Printf("Create Database: %s\n", fullPath)
	_, err := os.Stat(fullPath)
	if os.IsNotExist(err) {
		os.MkdirAll(dirPath, 0755)
		os.Create(fullPath)
	}

	db, err := sql.Open("sqlite3", fullPath)
	ProcessError(err)

	// create table
	_, err = db.Exec("CREATE TABLE IF NOT EXISTS `tasks` (" +
		"`id` INTEGER PRIMARY KEY AUTOINCREMENT," +
		"`uuid` VARCHAR(36) NOT NULL UNIQUE," +
		"`title` TEXT NOT NULL," +
		"`deleted` INTEGER NOT NULL DEFAULT 0," +
		"`updatedAt` INTEGER NOT NULL," +
		"`createdAt` INTEGER NOT NULL," +
		"`_ts` INTEGER NOT NULL" +
		")")
	ProcessError(err)

	// create ts index
	_, err = db.Exec("CREATE INDEX IF NOT EXISTS `index_tasks_ts` " +
		" ON `tasks` ( `_ts` )")
	ProcessError(err)

	connDB = db
	return true
}

// Close database connection
func Close() {
	if connDB != nil {
		connDB.Close()
		connDB = nil
	}
}
