package database

import (
	"Storyboard/backend/dao"
	"database/sql"
	"fmt"
)

// CreateTask in DB
func CreateTask(task dao.Task) bool {
	stmt, err := GetDB().Prepare("INSERT INTO `tasks` (" +
		"uuid, title, updatedAt, createdAt, _ts" +
		") VALUES (:uuid, :title, :updatedAt, :createdAt, :ts)")
	ProcessError(err)

	ts := GetTS()

	result, err := stmt.Exec(
		sql.Named("uuid", task.UUID),
		sql.Named("title", task.Title),
		sql.Named("updatedAt", task.UpdatedAt),
		sql.Named("createdAt", task.CreatedAt),
		sql.Named("ts", ts),
	)
	ProcessError(err)

	lastID, err := result.LastInsertId()
	ProcessError(err)

	return lastID > 0
}

// UpdateTask in DB
func UpdateTask(task dao.Task) bool {
	stmt, err := GetDB().Prepare("UPDATE `tasks` SET " +
		"`title` = :title, " +
		"`updatedAt` = :updatedAt, " +
		"`_ts` = :ts " +
		"WHERE `uuid` = :uuid ")
	ProcessError(err)

	ts := GetTS()

	result, err := stmt.Exec(
		sql.Named("title", task.Title),
		sql.Named("updatedAt", task.UpdatedAt),
		sql.Named("uuid", task.UUID),
		sql.Named("ts", ts),
	)

	affectRow, err := result.RowsAffected()
	ProcessError(err)

	fmt.Printf("Updated: %t\n", affectRow > 0)
	return affectRow > 0
}

// DeleteTask in DB
func DeleteTask(UUID string) bool {
	stmt, err := GetDB().Prepare("UPDATE `tasks` SET " +
		"`deleted` = 1," +
		"`_ts` = :ts " +
		"WHERE `uuid` = :uuid ")
	ProcessError(err)

	ts := GetTS()

	result, err := stmt.Exec(
		sql.Named("uuid", UUID),
		sql.Named("ts", ts),
	)

	affectRow, err := result.RowsAffected()
	ProcessError(err)

	fmt.Printf("Updated: %t\n", affectRow > 0)
	return affectRow > 0
}

// GetTask in DB
func GetTask(UUID string) *dao.Task {
	stmt, err := GetDB().Prepare("SELECT uuid, title, deleted, updatedAt, createdAt, _ts " +
		"FROM `tasks` WHERE `uuid` = :uuid ")
	ProcessError(err)

	row := stmt.QueryRow(sql.Named("uuid", UUID))

	var task dao.Task
	err = row.Scan(
		&task.UUID, &task.Title, &task.Deleted,
		&task.UpdatedAt, &task.CreatedAt, &task.TS,
	)
	if err == sql.ErrNoRows {
		return nil
	}
	return &task
}

// GetTasks in DB
func GetTasks(ts int64, limit int, offset int) []dao.Task {
	stmt, err := GetDB().Prepare("SELECT uuid, title, deleted, updatedAt, createdAt, _ts " +
		"FROM `tasks` WHERE `_ts` >= :ts ORDER BY `_ts` ASC LIMIT :limit OFFSET :offset")
	ProcessError(err)

	rows, err := stmt.Query(
		sql.Named("ts", ts),
		sql.Named("limit", limit),
		sql.Named("offset", offset),
	)
	ProcessError(err)

	var tasks []dao.Task = make([]dao.Task, 0, limit)
	for rows.Next() {
		var task dao.Task
		rows.Scan(
			&task.UUID, &task.Title, &task.Deleted,
			&task.UpdatedAt, &task.CreatedAt, &task.TS,
		)
		tasks = append(tasks, task)
	}
	return tasks
}
