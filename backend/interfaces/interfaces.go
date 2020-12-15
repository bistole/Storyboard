package interfaces

import (
	"database/sql"
	"io"
)

// Task is data object of Task
type Task struct {
	UUID    string `json:"uuid"`
	Title   string `json:"title"`
	Deleted int8   `json:"deleted"`

	CreatedAt int64 `json:"createdAt"`
	UpdatedAt int64 `json:"updatedAt"`
	TS        int64 `json:"_ts"`
}

// Photo is data object of Photo
type Photo struct {
	UUID      string `json:"uuid"`
	Filename  string `json:"filename"`
	Size      string `json:"size"`
	Mime      string `json:"mime"`
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
	GetDataFolder() string
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

// PhotoRepo is interface of photo package
type PhotoRepo interface {
	AddPhoto(filename string, mimeType string, size string, src io.Reader) (outPhoto *Photo, err error)
	DeletePhoto(UUID string) (outPhoto *Photo, err error)
	GetPhoto(UUID string) (src io.ReadCloser, err error)
	GetPhotoThumbnail(UUID string) (src io.ReadCloser, err error)
	GetPhotoMeta(UUID string) (outPhoto *Photo, err error)
	GetPhotoMetaByTS(ts int64, limit int, offset int) ([]Photo, error)
}

// RESTService is interface of RESTful service package
type RESTService interface {
	Start()
	Stop()
}
