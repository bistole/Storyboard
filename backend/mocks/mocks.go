package mocks

import (
	"database/sql"
	"io"
	"storyboard/backend/interfaces"
)

// Task is defined in interfaces
type Task = interfaces.Task
type Photo = interfaces.Photo

// ConfigMock to mock config
type ConfigMock struct {
	GetVendorNameFn   func() string
	GetAppNameFn      func() string
	GetDatabaseNameFn func() string
}

// GetVendorName mock config GetVendorName
func (c *ConfigMock) GetVendorName() string {
	return c.GetVendorNameFn()
}

// GetAppName mock config GetAppName
func (c *ConfigMock) GetAppName() string {
	return c.GetAppNameFn()
}

// GetDatabaseName mock config GetDatabaseName
func (c *ConfigMock) GetDatabaseName() string {
	return c.GetDatabaseNameFn()
}

// DatabaseMock to mock database service
type DatabaseMock struct {
	InitFn          func()
	GetConnectionFn func() *sql.DB
	GetTSFn         func() int64
	CloseFn         func()
}

// Init mock database service
func (d *DatabaseMock) Init() {
	d.InitFn()
}

// GetConnection mock database service
func (d *DatabaseMock) GetConnection() *sql.DB {
	return d.GetConnectionFn()
}

// GetTS mock database service
func (d *DatabaseMock) GetTS() int64 {
	return d.GetTSFn()
}

// Close mock database service
func (d *DatabaseMock) Close() {
	d.CloseFn()
}

// TaskRepoMock to mock task repo
type TaskRepoMock struct {
	CreateTaskFn    func(Task) (*Task, error)
	UpdateTaskFn    func(string, Task) (*Task, error)
	DeleteTaskFn    func(string, int64) (*Task, error)
	GetTaskByUUIDFn func(string) (*Task, error)
	GetTasksByTSFn  func(ts int64, limit int, offset int) ([]Task, error)
}

// CreateTask mock task repo
func (t *TaskRepoMock) CreateTask(task Task) (*Task, error) {
	return t.CreateTaskFn(task)
}

// UpdateTask mock task repo
func (t *TaskRepoMock) UpdateTask(UUID string, task Task) (*Task, error) {
	return t.UpdateTaskFn(UUID, task)
}

// DeleteTask mock task repo
func (t *TaskRepoMock) DeleteTask(UUID string, updatedAt int64) (*Task, error) {
	return t.DeleteTaskFn(UUID, updatedAt)
}

// GetTaskByUUID mock task repo
func (t *TaskRepoMock) GetTaskByUUID(UUID string) (*Task, error) {
	return t.GetTaskByUUIDFn(UUID)
}

// GetTasksByTS mock task repo
func (t *TaskRepoMock) GetTasksByTS(ts int64, limit int, offset int) ([]Task, error) {
	return t.GetTasksByTSFn(ts, limit, offset)
}

// PhotoRepoMock to mock photo repo
type PhotoRepoMock struct {
	AddPhotoFn          func(string, string, string, string, io.Reader, int64) (*Photo, error)
	DeletePhotoFn       func(string, int64) (*Photo, error)
	GetPhotoFn          func(string) (io.ReadCloser, error)
	GetPhotoThumbnailFn func(string) (io.ReadCloser, error)
	GetPhotoMetaFn      func(string) (*Photo, error)
	GetPhotoMetaByTSFn  func(ts int64, limit int, offset int) ([]Photo, error)
}

// AddPhoto mock photo repo
func (p *PhotoRepoMock) AddPhoto(uuid string, filename string, mime string, size string, src io.Reader, createdAt int64) (*Photo, error) {
	return p.AddPhotoFn(uuid, filename, mime, size, src, createdAt)
}

// DeletePhoto mock photo repo
func (p *PhotoRepoMock) DeletePhoto(UUID string, updatedAt int64) (*Photo, error) {
	return p.DeletePhotoFn(UUID, updatedAt)
}

// GetPhoto mock photo repo
func (p *PhotoRepoMock) GetPhoto(UUID string) (io.ReadCloser, error) {
	return p.GetPhotoFn(UUID)
}

// GetPhotoThumbnail mock photo repo
func (p *PhotoRepoMock) GetPhotoThumbnail(UUID string) (io.ReadCloser, error) {
	return p.GetPhotoThumbnailFn(UUID)
}

// GetPhotoMeta mock photo repo
func (p *PhotoRepoMock) GetPhotoMeta(UUID string) (*Photo, error) {
	return p.GetPhotoMetaFn(UUID)
}

// GetPhotoMetaByTS mock photo repo
func (p *PhotoRepoMock) GetPhotoMetaByTS(ts int64, limit int, offset int) ([]Photo, error) {
	return p.GetPhotoMetaByTSFn(ts, limit, offset)
}

// RESTMock to mock REST service
type RESTMock struct {
	StartFn func()
	StopFn  func()
}

// Start mock REST service
func (r *RESTMock) Start() {
	r.StartFn()
}

// Stop mock REST service
func (r *RESTMock) Stop() {
	r.StopFn()
}
