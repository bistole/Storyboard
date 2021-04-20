package mocks

import (
	"context"
	"database/sql"
	"io"
	"net"
	"net/http"
	"storyboard/backend/interfaces"
)

// Task is defined in interfaces
type Task = interfaces.Task

// Photo is defined in interfaces
type Photo = interfaces.Photo

// NetMock to mock package net
type NetMock struct {
	DialFn           func(string, string) (net.Conn, error)
	ConnCloseFn      func(net.Conn)
	ConnLocalAddrFn  func(net.Conn) net.Addr
	InterfacesFn     func() ([]net.Interface, error)
	InterfaceAddrsFn func(net.Interface) ([]net.Addr, error)
}

// Dial mock net Dial()
func (net NetMock) Dial(t string, ip string) (net.Conn, error) {
	return net.DialFn(t, ip)
}

// ConnClose mock net.Conn.Close()
func (net NetMock) ConnClose(conn net.Conn) {
	net.ConnCloseFn(conn)
}

// ConnLocalAddr mock net.Conn.Close()
func (net NetMock) ConnLocalAddr(conn net.Conn) net.Addr {
	return net.ConnLocalAddrFn(conn)
}

// Interfaces mock net Interfaces()
func (net NetMock) Interfaces() ([]net.Interface, error) {
	return net.InterfacesFn()
}

// InterfaceAddrs mock net.Interface.Addrs()
func (net NetMock) InterfaceAddrs(i net.Interface) ([]net.Addr, error) {
	return net.InterfaceAddrsFn(i)
}

// HTTPMock to mock package net/http
type HTTPMock struct {
	ListenAndServeFn func(*http.Server) error
	ShutdownFn       func(context.Context, *http.Server) error
}

// ListenAndServe mock net.http.Server.ListenAndServe()
func (http HTTPMock) ListenAndServe(server *http.Server) error {
	return http.ListenAndServeFn(server)
}

// Shutdown mock net.http.Server.Shutdown()
func (http HTTPMock) Shutdown(ctx context.Context, server *http.Server) error {
	return http.ShutdownFn(ctx, server)
}

// ConfigMock to mock config
type ConfigMock struct {
	GetHomeDirFn      func() string
	GetDatabaseNameFn func() string
	GetIPFn           func() string
	GetPortFn         func() int
	SetIPFn           func(string)
	SetPortFn         func(int)
}

// GetHomeDir mock config GetHomeDir
func (c *ConfigMock) GetHomeDir() string {
	return c.GetHomeDirFn()
}

// GetDatabaseName mock config GetDatabaseName
func (c *ConfigMock) GetDatabaseName() string {
	return c.GetDatabaseNameFn()
}

// GetIP get ip
func (c *ConfigMock) GetIP() string {
	return c.GetIPFn()
}

// SetIP set ip
func (c *ConfigMock) SetIP(ip string) {
	c.SetIPFn(ip)
}

// GetPort get port
func (c *ConfigMock) GetPort() int {
	return c.GetPortFn()
}

// SetPort set port
func (c *ConfigMock) SetPort(port int) {
	c.SetPortFn(port)
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
	AddPhotoFn          func(string, string, string, string, int32, io.Reader, int64) (*Photo, error)
	UpdatePhotoFn       func(string, Photo) (*Photo, error)
	DeletePhotoFn       func(string, int64) (*Photo, error)
	GetPhotoFn          func(string) (io.ReadCloser, error)
	GetPhotoThumbnailFn func(string) (io.ReadCloser, error)
	GetPhotoMetaFn      func(string) (*Photo, error)
	GetPhotoMetaByTSFn  func(ts int64, limit int, offset int) ([]Photo, error)
}

// AddPhoto mock photo repo
func (p *PhotoRepoMock) AddPhoto(uuid string, filename string, mime string, size string, direction int32, src io.Reader, createdAt int64) (*Photo, error) {
	return p.AddPhotoFn(uuid, filename, mime, size, direction, src, createdAt)
}

func (p *PhotoRepoMock) UpdatePhoto(uuid string, photo Photo) (*Photo, error) {
	return p.UpdatePhotoFn(uuid, photo)
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
	StartFn        func()
	StopFn         func()
	GetCurrentIPFn func() string
	SetCurrentIPFn func(string)
	GetServerIPsFn func() map[string]string
}

// Start mock REST service
func (r *RESTMock) Start() {
	r.StartFn()
}

// Stop mock REST service
func (r *RESTMock) Stop() {
	r.StopFn()
}

// GetCurrentIP get current ip
func (r *RESTMock) GetCurrentIP() string {
	return r.GetCurrentIPFn()
}

// SetCurrentIP set current ip
func (r *RESTMock) SetCurrentIP(ip string) {
	r.SetCurrentIPFn(ip)
}

// GetServerIPs get valid ips
func (r *RESTMock) GetServerIPs() map[string]string {
	return r.GetServerIPsFn()
}
