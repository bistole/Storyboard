package taskrepo

import (
	"storyboard/backend/interfaces"

	"database/sql"
	"fmt"
	"time"
)

// Task is defined in interfaces
type Task = interfaces.Task

// TaskRepo is Task repository implement
type TaskRepo struct {
	db interfaces.DatabaseService
}

// NewTaskRepo create instance of task repo
func NewTaskRepo(db interfaces.DatabaseService) TaskRepo {
	return TaskRepo{db}
}

// CreateTask in DB
func (t TaskRepo) CreateTask(inTask Task) (outTask *Task, err error) {
	// create task
	if err := t._createTask(inTask); err != nil {
		return nil, err
	}
	outTask, err = t._getTask(inTask.UUID)
	if err != nil {
		return nil, err
	}
	return outTask, nil
}

// UpdateTask in DB
func (t TaskRepo) UpdateTask(UUID string, inTask Task) (outTask *Task, err error) {
	task, err := t._getTask(UUID)
	if err != nil {
		return nil, fmt.Errorf("Task is not existed")
	}

	inTask.UUID = UUID
	inTask.CreatedAt = task.CreatedAt

	if err := t._updateTask(inTask); err != nil {
		return nil, err
	}
	outTask, err = t._getTask(UUID)
	if err != nil {
		return nil, err
	}
	return outTask, nil
}

// DeleteTask in DB
func (t TaskRepo) DeleteTask(UUID string) (outTask *Task, err error) {

	updatedAt := time.Now().Unix()
	if err := t._deleteTask(UUID, updatedAt); err != nil {
		return nil, err
	}
	outTask, err = t._getTask(UUID)
	if err != nil {
		return nil, err
	}
	return outTask, nil
}

// GetTaskByUUID in DB
func (t TaskRepo) GetTaskByUUID(UUID string) (outTask *Task, err error) {
	outTask, err = t._getTask(UUID)
	if err != nil {
		return nil, err
	}
	return outTask, nil
}

func (t TaskRepo) _createTask(task Task) error {
	db := t.db.GetConnection()
	stmt, err := db.Prepare("INSERT INTO `tasks` (" +
		"uuid, title, updatedAt, createdAt, _ts" +
		") VALUES (:uuid, :title, :updatedAt, :createdAt, :ts)")
	if err != nil {
		return err
	}

	ts := t.db.GetTS()

	result, err := stmt.Exec(
		sql.Named("uuid", task.UUID),
		sql.Named("title", task.Title),
		sql.Named("updatedAt", task.UpdatedAt),
		sql.Named("createdAt", task.CreatedAt),
		sql.Named("ts", ts),
	)
	if err != nil {
		return err
	}

	lastID, err := result.LastInsertId()
	if err != nil {
		return err
	}

	if lastID > 0 {
		return nil
	}
	return fmt.Errorf("Failed to create task")
}

// UpdateTask in DB
func (t TaskRepo) _updateTask(task Task) error {
	db := t.db.GetConnection()
	stmt, err := db.Prepare("UPDATE `tasks` SET " +
		"`title` = :title, " +
		"`updatedAt` = :updatedAt, " +
		"`_ts` = :ts " +
		"WHERE `uuid` = :uuid ")
	if err != nil {
		return err
	}

	ts := t.db.GetTS()

	result, err := stmt.Exec(
		sql.Named("title", task.Title),
		sql.Named("updatedAt", task.UpdatedAt),
		sql.Named("uuid", task.UUID),
		sql.Named("ts", ts),
	)
	if err != nil {
		return err
	}

	affectRow, err := result.RowsAffected()
	if err != nil {
		return err
	}

	fmt.Printf("Updated: %t\n", affectRow > 0)
	if affectRow > 0 {
		return nil
	}
	return fmt.Errorf("Failed to update task")
}

// DeleteTask in DB
func (t TaskRepo) _deleteTask(UUID string, updatedAt int64) error {
	db := t.db.GetConnection()
	stmt, err := db.Prepare("UPDATE `tasks` SET " +
		"`deleted` = 1," +
		"`updatedAt` = :updatedAt," +
		"`_ts` = :ts " +
		"WHERE `uuid` = :uuid ")
	if err != nil {
		return err
	}

	ts := t.db.GetTS()

	result, err := stmt.Exec(
		sql.Named("uuid", UUID),
		sql.Named("updatedAt", updatedAt),
		sql.Named("ts", ts),
	)
	if err != nil {
		return err
	}

	affectRow, err := result.RowsAffected()
	if err != nil {
		return err
	}

	fmt.Printf("Deleted: %t\n", affectRow > 0)
	if affectRow > 0 {
		return nil
	}
	return fmt.Errorf("Failed to delete task")
}

// GetTask in DB
func (t TaskRepo) _getTask(UUID string) (*Task, error) {
	db := t.db.GetConnection()
	stmt, err := db.Prepare("SELECT uuid, title, deleted, updatedAt, createdAt, _ts " +
		"FROM `tasks` WHERE `uuid` = :uuid ")
	if err != nil {
		return nil, err
	}

	row := stmt.QueryRow(sql.Named("uuid", UUID))

	var task Task
	err = row.Scan(
		&task.UUID, &task.Title, &task.Deleted,
		&task.UpdatedAt, &task.CreatedAt, &task.TS,
	)
	if err == sql.ErrNoRows {
		return nil, err
	}
	return &task, nil
}

// GetTasksByTS in DB
func (t TaskRepo) GetTasksByTS(ts int64, limit int, offset int) (tasks []Task, err error) {
	db := t.db.GetConnection()
	stmt, err := db.Prepare("SELECT uuid, title, deleted, updatedAt, createdAt, _ts " +
		"FROM `tasks` WHERE `_ts` >= :ts ORDER BY `_ts` ASC LIMIT :limit OFFSET :offset")
	if err != nil {
		return nil, err
	}

	rows, err := stmt.Query(
		sql.Named("ts", ts),
		sql.Named("limit", limit),
		sql.Named("offset", offset),
	)
	if err != nil {
		return nil, err
	}

	tasks = make([]Task, 0, limit)
	for rows.Next() {
		var task Task
		rows.Scan(
			&task.UUID, &task.Title, &task.Deleted,
			&task.UpdatedAt, &task.CreatedAt, &task.TS,
		)
		tasks = append(tasks, task)
	}
	return tasks, nil
}
