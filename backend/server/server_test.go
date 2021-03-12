package server

import (
	"context"
	"net"
	"net/http"
	"storyboard/backend/mocks"
	"storyboard/backend/wrapper"
	"testing"
	"time"
)

type MockNetConn struct {
	remote net.Addr
	local  net.Addr
}

func (conn MockNetConn) Read([]byte) (n int, err error)     { return 0, nil }
func (conn MockNetConn) Write(b []byte) (n int, err error)  { return 0, nil }
func (conn MockNetConn) Close() error                       { return nil }
func (conn MockNetConn) LocalAddr() net.Addr                { return conn.local }
func (conn MockNetConn) RemoteAddr() net.Addr               { return conn.remote }
func (conn MockNetConn) SetDeadline(t time.Time) error      { return nil }
func (conn MockNetConn) SetReadDeadline(t time.Time) error  { return nil }
func (conn MockNetConn) SetWriteDeadline(t time.Time) error { return nil }

func MockNetProxy() *mocks.NetMock {
	var netMock = &mocks.NetMock{
		DialFn: func(t string, ip string) (net.Conn, error) {
			return MockNetConn{
				remote: &net.UDPAddr{
					IP:   []byte{192, 168, 3, 18},
					Port: 3000,
					Zone: "hello",
				},
				local: &net.UDPAddr{
					IP:   []byte{192, 168, 3, 18},
					Port: 3000,
					Zone: "hello",
				},
			}, nil
		},
		InterfacesFn: func() ([]net.Interface, error) {
			return make([]net.Interface, 0), nil
		},
	}
	return netMock
}

func TestServerStartup(t *testing.T) {
	var savedIP string
	var configMock = &mocks.ConfigMock{
		GetIPFn: func() string {
			return savedIP
		},
		SetIPFn: func(ip string) {
			savedIP = ip
		},
	}
	netMock := wrapper.NewNetWrapper()
	httpMock := wrapper.NewHTTPWrapper()
	var taskRepoMock = &mocks.TaskRepoMock{}
	var photoRepoMock = &mocks.PhotoRepoMock{}
	ss := NewRESTServer(netMock, httpMock, configMock, taskRepoMock, photoRepoMock)
	ss.Start()
	ss.Stop()
}

func TestSetCurrentIP(t *testing.T) {
	oldIP := "192.168.0.11"
	oldIPBytes := []byte{192, 168, 0, 11}
	newIP := "192.168.0.12"
	newIPBytes := []byte{192, 168, 0, 12}

	// config ip
	var ipSaved = oldIP
	configMock := &mocks.ConfigMock{
		GetIPFn: func() string {
			return ipSaved
		},
		SetIPFn: func(ip string) {
			ipSaved = ip
		},
	}
	// mock net
	netMock := &mocks.NetMock{
		DialFn: func(string, string) (net.Conn, error) {
			return &net.UDPConn{}, nil
		},
		ConnCloseFn: func(net.Conn) {},
		ConnLocalAddrFn: func(net.Conn) net.Addr {
			return &net.UDPAddr{
				IP:   oldIPBytes,
				Port: 3000,
				Zone: "hello",
			}
		},
		InterfacesFn: func() ([]net.Interface, error) {
			interfaces := make([]net.Interface, 1)
			interfaces[0].Index = 1
			interfaces[0].MTU = 1
			interfaces[0].Name = "eth0"
			interfaces[0].HardwareAddr = newIPBytes
			interfaces[0].Flags = net.FlagUp & net.FlagPointToPoint
			return interfaces, nil
		},
		InterfaceAddrsFn: func(i net.Interface) ([]net.Addr, error) {
			addrs := make([]net.Addr, 1)
			addrs[0] = &net.IPNet{
				IP:   newIPBytes,
				Mask: []byte{255, 255, 255, 0},
			}
			return addrs, nil
		},
	}

	var listenAndServeCalledTimes = 0
	var shutdownCalledTimes = 0
	var shutdown = make(chan bool)
	var restarted = make(chan bool)
	httpMock := &mocks.HTTPMock{
		ListenAndServeFn: func(server *http.Server) error {
			listenAndServeCalledTimes++
			t.Log(server.Addr)
			if server.Addr == oldIP+":3000" {
				// first time
				<-shutdown
				return http.ErrServerClosed
			} else if server.Addr == newIP+":3000" {
				// second time
				restarted <- true
				return nil
			} else {
				t.Errorf("Unexpected addr: %s\n", server.Addr)
			}
			return nil
		},
		ShutdownFn: func(ctx context.Context, server *http.Server) error {
			if shutdownCalledTimes == 0 {
				shutdown <- true
			}
			shutdownCalledTimes++
			return nil
		},
	}
	taskRepoMock := &mocks.TaskRepoMock{}
	photoRepoMock := &mocks.PhotoRepoMock{}
	ss := NewRESTServer(netMock, httpMock, configMock, taskRepoMock, photoRepoMock)
	ss.Start()
	ss.SetCurrentIP(newIP)

	<-restarted

	if listenAndServeCalledTimes != 2 {
		t.Error("Should call listenAndServe twice")
	}
	if shutdownCalledTimes != 1 {
		t.Error("Should call shutdown once")
	}
	if ipSaved != newIP {
		t.Error("IP is not saved to config file")
	}
}

func TestGetCurrenctIPWhichIsValid(t *testing.T) {
	oldIP := "192.168.0.33"
	oldIPBytes := []byte{192, 168, 0, 33}
	// config ip
	var ipSaved = oldIP
	configMock := &mocks.ConfigMock{
		GetIPFn: func() string {
			return ipSaved
		},
		SetIPFn: func(ip string) {
			ipSaved = ip
		},
	}
	netMock := &mocks.NetMock{
		DialFn: func(string, string) (net.Conn, error) {
			return &net.UDPConn{}, nil
		},
		ConnCloseFn: func(net.Conn) {},
		ConnLocalAddrFn: func(net.Conn) net.Addr {
			return &net.UDPAddr{
				IP:   oldIPBytes,
				Port: 3000,
				Zone: "hello",
			}
		},
		InterfacesFn: func() ([]net.Interface, error) {
			interfaces := make([]net.Interface, 1)
			interfaces[0].Index = 1
			interfaces[0].MTU = 1
			interfaces[0].Name = "eth0"
			interfaces[0].HardwareAddr = oldIPBytes
			interfaces[0].Flags = net.FlagUp & net.FlagPointToPoint
			return interfaces, nil
		},
		InterfaceAddrsFn: func(i net.Interface) ([]net.Addr, error) {
			addrs := make([]net.Addr, 1)
			addrs[0] = &net.IPNet{
				IP:   oldIPBytes,
				Mask: []byte{255, 255, 255, 0},
			}
			return addrs, nil
		},
	}
	taskRepoMock := &mocks.TaskRepoMock{}
	photoRepoMock := &mocks.PhotoRepoMock{}
	httpMock := mocks.HTTPMock{}
	ss := NewRESTServer(netMock, httpMock, configMock, taskRepoMock, photoRepoMock)

	newIP := ss.GetCurrentIP()
	if newIP != oldIP {
		t.Errorf("Get unexpected current ip: %s\n", newIP)
	}
}

func TestServerValidIPs(t *testing.T) {
	configMock := &mocks.ConfigMock{}
	netMock := &mocks.NetMock{
		DialFn: func(string, string) (net.Conn, error) {
			return nil, nil
		},
		InterfacesFn: func() ([]net.Interface, error) {
			interfaces := make([]net.Interface, 1)
			interfaces[0].Index = 1
			interfaces[0].MTU = 1
			interfaces[0].Name = "eth0"
			interfaces[0].HardwareAddr = []byte{192, 168, 77, 88}
			interfaces[0].Flags = net.FlagUp & net.FlagPointToPoint
			return interfaces, nil
		},
		InterfaceAddrsFn: func(i net.Interface) ([]net.Addr, error) {
			addrs := make([]net.Addr, 1)
			addrs[0] = &net.IPNet{
				IP:   []byte{192, 168, 77, 88},
				Mask: []byte{255, 255, 255, 0},
			}
			return addrs, nil
		},
	}
	httpMock := wrapper.NewHTTPWrapper()
	taskRepoMock := &mocks.TaskRepoMock{}
	photoRepoMock := &mocks.PhotoRepoMock{}
	ss := NewRESTServer(netMock, httpMock, configMock, taskRepoMock, photoRepoMock)
	ips := ss.GetServerIPs()
	if len(ips) != 1 || ips["eth0"] != "192.168.77.88" {
		t.Error("expected server ips")
	}
}
