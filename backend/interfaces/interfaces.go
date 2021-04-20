package interfaces

import (
	"context"
	"database/sql"
	"io"
	"net"
	"net/http"
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
	Direction int32  `json:"direction"`
	Deleted   int8   `json:"deleted"`
	CreatedAt int64  `json:"createdAt"`
	UpdatedAt int64  `json:"updatedAt"`
	TS        int64  `json:"_ts"`
}

// NetProxy is interface of package net
type NetProxy interface {
	Dial(string, string) (net.Conn, error)
	ConnClose(net.Conn)
	ConnLocalAddr(net.Conn) net.Addr
	Interfaces() ([]net.Interface, error)
	InterfaceAddrs(net.Interface) ([]net.Addr, error)
}

// HTTPProxy is interface of package net/http
type HTTPProxy interface {
	ListenAndServe(s *http.Server) error
	Shutdown(ctx context.Context, s *http.Server) error
}

// ConfigService is interface of config package
type ConfigService interface {
	GetHomeDir() string
	GetDatabaseName() string
	GetIP() string
	SetIP(string)
	GetPort() int
	SetPort(int)
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
	DeleteTask(string, int64) (*Task, error)
	GetTaskByUUID(string) (*Task, error)
	GetTasksByTS(ts int64, limit int, offset int) ([]Task, error)
}

// PhotoRepo is interface of photo package
type PhotoRepo interface {
	AddPhoto(uuid string, filename string, mimeType string, size string, direction int32, src io.Reader,
		createdAt int64) (outPhoto *Photo, err error)
	UpdatePhoto(string, Photo) (outPhoto *Photo, err error)
	DeletePhoto(UUID string, updatedAt int64) (outPhoto *Photo, err error)
	GetPhoto(UUID string) (src io.ReadCloser, err error)
	GetPhotoThumbnail(UUID string) (src io.ReadCloser, err error)
	GetPhotoMeta(UUID string) (outPhoto *Photo, err error)
	GetPhotoMetaByTS(ts int64, limit int, offset int) ([]Photo, error)
}

// RESTService is interface of RESTful service package
type RESTService interface {
	Start()
	Stop()
	GetCurrentIP() string
	SetCurrentIP(string)
	GetServerIPs() map[string]string
}
