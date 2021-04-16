package server

import (
	"context"
	"log"
	"net"
	"net/http"
	"storyboard/backend/interfaces"
	"sync"
	"time"

	"github.com/gorilla/mux"
)

// RESTServer is wrapper for http server and wait group
type RESTServer struct {
	Config      interfaces.ConfigService
	Net         interfaces.NetProxy
	HTTP        interfaces.HTTPProxy
	ServerIP    string
	Server      *http.Server
	Wg          *sync.WaitGroup
	TaskRepo    interfaces.TaskRepo
	PhotoRepo   interfaces.PhotoRepo
	EventServer eventServer
}

// NewRESTServer create REST server
func NewRESTServer(
	net interfaces.NetProxy,
	http interfaces.HTTPProxy,
	config interfaces.ConfigService,
	taskRepo interfaces.TaskRepo,
	photoRepo interfaces.PhotoRepo,
) *RESTServer {
	var wg = &sync.WaitGroup{}
	return &RESTServer{
		Config:    config,
		Net:       net,
		HTTP:      http,
		ServerIP:  "",
		Server:    nil,
		Wg:        wg,
		TaskRepo:  taskRepo,
		PhotoRepo: photoRepo,
	}
}

func (rs RESTServer) route() *mux.Router {
	r := mux.NewRouter()
	r.HandleFunc("/ping", rs.Ping).Methods("GET")
	r.HandleFunc("/tasks", rs.GetTasks).Methods("GET")
	r.HandleFunc("/tasks", rs.CreateTask).Methods("POST")
	r.HandleFunc("/tasks/{id}", rs.GetTask).Methods("GET")
	r.HandleFunc("/tasks/{id}", rs.UpdateTask).Methods("POST")
	r.HandleFunc("/tasks/{id}", rs.DeleteTask).Methods("DELETE")
	r.HandleFunc("/photos", rs.GetPhotos).Methods("GET")
	r.HandleFunc("/photos", rs.UploadPhoto).Methods("POST")
	r.HandleFunc("/photos/{id}", rs.DownloadPhoto).Methods("GET")
	r.HandleFunc("/photos/{id}", rs.UpdatePhoto).Methods("POST")
	r.HandleFunc("/photos/{id}", rs.DeletePhoto).Methods("DELETE")
	r.HandleFunc("/photos/{id}/thumbnail", rs.ThumbnailPhoto).Methods("GET")
	r.HandleFunc("/photos/{id}/meta", rs.GetPhoto).Methods("GET")
	return r
}

// Start to build RESTful API Server
func (rs *RESTServer) Start() {
	rs.Wg.Add(1)

	rs.EventServer = *createEventServer()

	var route = rs.route()
	// add event server to standard route
	rs.EventServer.route(route)
	go rs.EventServer.MainLoop()
	go rs.EventServer.KeepAlive()

	ip := rs.GetCurrentIP()
	rs.Server = &http.Server{
		Addr:    ip + ":3000",
		Handler: route,
	}

	go func() {
		defer func() {
			rs.Server = nil
			rs.Wg.Done()
		}()

		log.Println("Started: ", ip)
		if err := rs.HTTP.ListenAndServe(rs.Server); err != nil && err != http.ErrServerClosed {
			log.Fatalf("ListenAndServe(): %v", err)
		}
	}()
}

// Stop the RESTful server
func (rs *RESTServer) Stop() {
	ctx, cancelFunc := context.WithTimeout(
		context.Background(),
		5*time.Second,
	)
	defer cancelFunc()

	// stop event server
	rs.EventServer.End()

	err := rs.HTTP.Shutdown(ctx, rs.Server)
	if err != nil {
		log.Fatalf("Shutdown(): %v", err)
	}

	rs.Wg.Wait()

	log.Println("Stopped")
}

// GetCurrentIP set current ip
func (rs *RESTServer) GetCurrentIP() string {
	if rs.ServerIP != "" {
		return rs.ServerIP
	}
	var configIP = rs.Config.GetIP()
	if configIP == "" {
		configIP = rs.getOutboundIP()
		rs.Config.SetIP(configIP)
	} else {
		var valid = false
		candidates := rs.GetServerIPs()
		for _, val := range candidates {
			if val == configIP {
				valid = true
				break
			}
		}
		if valid != true {
			// config ip is not valid, use outbound one
			configIP := rs.getOutboundIP()
			rs.Config.SetIP(configIP)
		}
	}
	rs.ServerIP = configIP
	return configIP
}

// SetCurrentIP set current ip
func (rs *RESTServer) SetCurrentIP(ip string) {
	if rs.ServerIP != ip {
		rs.ServerIP = ip
		rs.Config.SetIP(ip)

		// restart the server with right ip
		rs.Stop()
		rs.Start()
	}
}

// GetOutboundIP get most possible ip address to bind
func (rs *RESTServer) getOutboundIP() string {
	conn, err := rs.Net.Dial("udp", "8.8.8.8:80")
	if err != nil {
		panic(err)
	}
	defer rs.Net.ConnClose(conn)

	localIP := rs.Net.ConnLocalAddr(conn).(*net.UDPAddr).IP.String()
	log.Println("Outbound IP: " + localIP)
	return localIP
}

// GetServerIPs get available server ips
func (rs *RESTServer) GetServerIPs() map[string]string {
	ifaces, err := rs.Net.Interfaces()
	if err != nil {
		panic(err)
	}

	var results map[string]string = make(map[string]string)
	for _, i := range ifaces {
		addrs, err := rs.Net.InterfaceAddrs(i)
		if err != nil {
			panic(err)
		}
		if len(addrs) == 0 {
			continue
		}
		for _, addr := range addrs {
			var ip net.IP
			switch v := addr.(type) {
			case *net.IPNet:
				ip = v.IP
			case *net.IPAddr:
				ip = v.IP

			}
			if ip.IsLoopback() {
				continue
			}
			var v4 = ip.To4()
			if v4 != nil {
				results[i.Name] = v4.String()
				log.Println("Found IP: " + i.Name + " -> " + v4.String())
			}
		}
	}
	return results
}
