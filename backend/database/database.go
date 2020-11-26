package database

import (
	"Storyboard/backend/config"
	"Storyboard/backend/dao"
	"database/sql"
	"fmt"
	"os"
	"path"

	"github.com/adrg/xdg"
	_ "github.com/mattn/go-sqlite3"
)

var connDB *sql.DB = nil

// InitDatabase to init database
func InitDatabase() bool {
	if connDB != nil {
		return true
	}

	fullPath := path.Join(xdg.DataHome, config.VendorName, config.AppName, "foo.db")
	fmt.Printf("Create Database: %s\n", fullPath)
	_, err := os.Stat(fullPath)
	if os.IsNotExist(err) {
		os.MkdirAll(path.Join(xdg.DataHome, config.VendorName, config.AppName), 0755)
		os.Create(fullPath)
	}

	db, err := sql.Open("sqlite3", fullPath)
	if err != nil {
		panic(err)
	}

	_, err = db.Exec("CREATE TABLE IF NOT EXISTS `tasks` (" +
		"`id` INTEGER PRIMARY KEY AUTOINCREMENT," +
		"`uuid` VARCHAR(36) NOT NULL," +
		"`title` TEXT NOT NULL," +
		"`updatedAt` INTEGER NOT NULL," +
		"`createdAt` INTEGER NOT NULL" +
		")")
	if err != nil {
		processError(err)
	}

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

func processError(err error) {
	panic(err)
}

// CreateTask in DB
func CreateTask(task dao.Task) bool {
	stmt, err := connDB.Prepare("INSERT INTO `tasks` (" +
		"uuid, title, updatedAt, createdAt" +
		") VALUES (:uuid, :title, :updatedAt, :createdAt)")
	if err != nil {
		processError(err)
	}

	result, err := stmt.Exec(
		sql.Named("title", task.Title),
		sql.Named("updatedAt", task.UpdatedAt),
		sql.Named("createdAt", task.CreatedAt),
		sql.Named("uuid", task.UUID))
	if err != nil {
		processError(err)
	}

	lastID, err := result.LastInsertId()
	if err != nil {
		processError(err)
	}

	return lastID > 0
}

// UpdateTask in DB
func UpdateTask(task dao.Task) bool {
	stmt, err := connDB.Prepare("UPDATE `tasks` SET " +
		"`title` = :title, " +
		"`updatedAt` = :updatedAt " +
		"WHERE `uuid` = :uuid ")
	if err != nil {
		processError(err)
	}

	result, err := stmt.Exec(
		sql.Named("title", task.Title),
		sql.Named("updatedAt", task.UpdatedAt),
		sql.Named("uuid", task.UUID))

	affectRow, err := result.RowsAffected()
	if err != nil {
		processError(err)
	}

	fmt.Printf("Updated: %t\n", affectRow > 0)
	return affectRow > 0
}

// DeleteTask in DB
func DeleteTask(UUID string) bool {
	stmt, err := connDB.Prepare("DELETE FROM `tasks` WHERE `uuid` = :uuid")
	if err != nil {
		processError(err)
	}

	result, err := stmt.Exec(sql.Named("uuid", UUID))

	affectRow, err := result.RowsAffected()
	if err != nil {
		processError(err)
	}

	fmt.Printf("Updated: %t\n", affectRow > 0)
	return affectRow > 0
}

// GetTask in DB
func GetTask(UUID string) *dao.Task {
	stmt, err := connDB.Prepare("SELECT uuid, title, updatedAt, createdAt " +
		"FROM `tasks` WHERE `uuid` = :uuid ")
	if err != nil {
		processError(err)
	}

	row := stmt.QueryRow(sql.Named("uuid", UUID))

	var task dao.Task
	err = row.Scan(&task.UUID, &task.Title, &task.UpdatedAt, &task.CreatedAt)
	if err == sql.ErrNoRows {
		return nil
	}
	return &task
}

// GetTasks in DB
func GetTasks(limit int, offset int) []dao.Task {
	stmt, err := connDB.Prepare("SELECT uuid, title, updatedAt, createdAt " +
		"FROM `tasks` LIMIT :limit OFFSET :offset")
	if err != nil {
		processError(err)
	}

	rows, err := stmt.Query(sql.Named("limit", limit), sql.Named("offset", offset))
	if err != nil {
		processError(err)
	}

	var tasks []dao.Task = make([]dao.Task, 0, limit)
	for rows.Next() {
		var task dao.Task
		rows.Scan(&task.UUID, &task.Title, &task.UpdatedAt, &task.CreatedAt)
		tasks = append(tasks, task)
	}
	return tasks
}
