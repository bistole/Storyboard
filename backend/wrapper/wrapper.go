package wrapper

import (
	"context"
	"net"
	"net/http"
)

// NetWrapper implement NetProxy interface
type NetWrapper struct{}

// Dial same as net.Dial()
func (n NetWrapper) Dial(t string, ip string) (net.Conn, error) {
	return net.Dial(t, ip)
}

// ConnClose same as net.Conn.Close()
func (n NetWrapper) ConnClose(conn net.Conn) {
	conn.Close()
}

// ConnLocalAddr same as net.Conn.LocalAddr()
func (n NetWrapper) ConnLocalAddr(conn net.Conn) net.Addr {
	return conn.LocalAddr()
}

// Interfaces same as net.Interfaces()
func (n NetWrapper) Interfaces() ([]net.Interface, error) {
	return net.Interfaces()
}

// InterfaceAddrs same as net.Interface.Addrs()
func (n NetWrapper) InterfaceAddrs(i net.Interface) ([]net.Addr, error) {
	return i.Addrs()
}

// NewNetWrapper create a NetWrapper instance
func NewNetWrapper() *NetWrapper {
	return &NetWrapper{}
}

// HTTPWrapper implement HTTPProxy interface
type HTTPWrapper struct{}

// ListenAndServe same as net.Server.ListenAndServe()
func (h HTTPWrapper) ListenAndServe(s *http.Server) error {
	return s.ListenAndServe()
}

// Shutdown same as net.Server.Shutdown()
func (h HTTPWrapper) Shutdown(ctx context.Context, s *http.Server) error {
	return s.Shutdown(ctx)
}

// NewHTTPWrapper create a HTTPWrapper instance
func NewHTTPWrapper() *HTTPWrapper {
	return &HTTPWrapper{}
}
