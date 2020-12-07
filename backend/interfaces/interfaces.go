package interfaces

import "database/sql"

// Task is data object of Task
type Task struct {
	UUID      string `json:"uuid"`
	Title     string `json:"title"`
	Deleted   int8   `json:"deleted"`
	CreatedAt int64  `json:"createdAt"`
	UpdatedAt int64  `json:"updatedAt"`
	TS        int64  `json:"_ts"`
}

// ConfigService is interface of config package
type ConfigService interface {
	GetVendorName() string
	GetAppName() string
	GetDatabaseName() string
}

// DatabaseService is interface of database package
type DatabaseService interface {
	Init()
	GetConnection() *sql.DB
	GetTS() int64
	Close()
}

// TaskRepo is interface of task package
type TaskRepo interface {
	CreateTask(Task) (*Task, error)
	UpdateTask(string, Task) (*Task, error)
	DeleteTask(string) (*Task, error)
	GetTaskByUUID(string) (*Task, error)
	GetTasksByTS(ts int64, limit int, offset int) ([]Task, error)
}

// RESTService is interface of RESTful service package
type RESTService interface {
	Start()
	Stop()
}
