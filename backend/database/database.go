package database

// TODO: test getTS
// TODO: test createDBInstance when db file exists
// TODO: test error cases

import (
	"database/sql"
	"errors"
	"log"
	"os"
	"path"
	"storyboard/backend/interfaces"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

// Database is implement of Database service
type Database struct {
	connDB *sql.DB
	config interfaces.ConfigService
}

// NewDatabaseService create instance of database service
func NewDatabaseService(config interfaces.ConfigService) *Database {
	return &Database{
		connDB: nil,
		config: config,
	}
}

// ProcessError process if error raised
func processError(prefix string, err error) {
	if err != nil {
		log.Fatalf("%s: %v", prefix, err)
	}
}

// GetConnection get connection to db
func (d Database) GetConnection() *sql.DB {
	if d.connDB == nil {
		processError("GetConnection", errors.New("Call Init() before GetConnection()"))
	}
	return d.connDB
}

// GetTS get transaction ID
func (d Database) GetTS() int64 {
	return time.Now().UnixNano()
}

// GetDataFolder get data folder
func (d Database) GetDataFolder() string {
	return d.config.GetHomeDir()
}

func (d Database) createDBInstance(dirPath string, dbName string) (fullPath string, existed bool) {
	fullPath = path.Join(dirPath, dbName)
	log.Printf("Create Database: %s\n", fullPath)
	_, err := os.Stat(fullPath)
	if os.IsNotExist(err) {
		os.MkdirAll(dirPath, 0755)
		os.Create(fullPath)
		return fullPath, false
	}
	return fullPath, true
}

func (d Database) initDBInstance() {
	ver := d._getUserVersion()
	if ver < 1 {
		d._initFromBegin()
	}
	if ver < 2 {
		d._upgradeToVer2()
	}
}

func (d Database) _getUserVersion() int64 {
	row := d.connDB.QueryRow("PRAGMA user_version")

	var ver int64
	err := row.Scan(&ver)
	processError("_getUserVersion", err)

	return ver
}

func (d Database) _initFromBegin() {
	// create note table
	_, err := d.connDB.Exec("CREATE TABLE IF NOT EXISTS `notes` (" +
		"`id` INTEGER PRIMARY KEY AUTOINCREMENT," +
		"`uuid` VARCHAR(36) NOT NULL UNIQUE," +
		"`title` TEXT NOT NULL," +
		"`deleted` INTEGER NOT NULL DEFAULT 0," +
		"`updatedAt` INTEGER NOT NULL," +
		"`createdAt` INTEGER NOT NULL," +
		"`_ts` INTEGER NOT NULL" +
		")")
	processError("_initFromBegin", err)

	// create note ts index
	_, err = d.connDB.Exec("CREATE INDEX IF NOT EXISTS `index_notes_ts` " +
		" ON `notes` ( `_ts` )")
	processError("_initFromBegin", err)

	// create photo table
	_, err = d.connDB.Exec("CREATE TABLE IF NOT EXISTS `photos` (" +
		"`id` INTEGER PRIMARY KEY AUTOINCREMENT," +
		"`uuid` VARCHAR(36) NOT NULL UNIQUE," +
		"`filename` TEXT NOT NULL," +
		"`size` VARCHAR(16) NOT NULL," +
		"`mime` VARCHAR(24) NOT NULL," +
		"`deleted` INTEGER NOT NULL DEFAULT 0," +
		"`updatedAt` INTEGER NOT NULL," +
		"`createdAt` INTEGER NOT NULL," +
		"`_ts` INTEGER NOT NULL" +
		")")
	processError("_initFromBegin", err)

	// create photo ts index
	_, err = d.connDB.Exec("CREATE INDEX IF NOT EXISTS `index_photos_ts` " +
		" ON `photos` ( `_ts` )")
	processError("_initFromBegin", err)

	_, err = d.connDB.Exec("PRAGMA user_version=1")
	processError("_initFromBegin", err)
}

func (d Database) _upgradeToVer2() {
	_, err := d.connDB.Exec("ALTER TABLE `photos` " +
		"ADD COLUMN `direction` INT NOT NULL DEFAULT 0")
	processError("_upgradeToVer2", err)

	_, err = d.connDB.Exec("PRAGMA user_version=2")
	processError("_upgradeToVer2", err)
}

// Init to init database
func (d *Database) Init() {
	// create folder if required
	dirPath := d.GetDataFolder()
	fullPath, _ := d.createDBInstance(dirPath, d.config.GetDatabaseName())

	db, err := sql.Open("sqlite3", fullPath)
	processError("Init", err)

	d.connDB = db

	d.initDBInstance()
}

// Close database connection
func (d *Database) Close() {
	if d.connDB != nil {
		d.connDB.Close()
		d.connDB = nil
	}
}
