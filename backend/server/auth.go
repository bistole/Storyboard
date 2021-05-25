package server

// TODO: test sse when missing client-id
// TODO: test sse client close
// TODO: test ping/pong

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/mux"
)

const clientNobody = "NOBODY"

// Ping to check server status
func (rs RESTServer) Ping(w http.ResponseWriter, r *http.Request) {
	type Succ struct {
		Pong bool `json:"pong"`
	}
	var response Succ
	response.Pong = true
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(w).Encode(response)
}

const keepAliveInterval = time.Second * 60

const actionNotify string = "notify"
const actionKeepalive string = "alive"
const actionWelcome string = "welcome"
const actionError string = "error"
const actionClose string = "close"

type serverEventData struct {
	Action string            `json:"action"`
	Params map[string]string `json:"params"`
	TS     int64             `json:"ts"`
}

type serverEvent struct {
	clientID string
	data     serverEventData
}

type eventServerClient struct {
	channel  chan []byte
	clientID string
}

type eventServer struct {
	clients       map[string]chan []byte
	newClient     chan eventServerClient
	closingClient chan eventServerClient
	message       chan serverEvent
	kldone        chan bool
	done          chan bool
}

func createEventServer() *eventServer {
	return &eventServer{
		make(map[string]chan []byte),
		make(chan eventServerClient),
		make(chan eventServerClient),
		make(chan serverEvent),
		make(chan bool),
		make(chan bool),
	}
}

func (es *eventServer) sendEvent(clientID string, action string, params *map[string]string) bool {
	blankParams := map[string]string{}

	pack := serverEvent{
		clientID: clientID,
		data: serverEventData{
			Action: action,
			TS:     time.Now().Unix(),
		},
	}
	if params != nil {
		pack.data.Params = *params
	} else {
		pack.data.Params = blankParams
	}

	if es.message != nil {
		es.message <- pack
		return true
	}
	return false
}

func (es *eventServer) sendWelcome(channel chan []byte) {
	data := serverEventData{
		Action: actionWelcome,
		TS:     time.Now().Unix(),
	}
	msg, err := json.Marshal(data)
	if err == nil {
		channel <- msg
		log.Println("ES Welcome: Sent")
	}
}

// EventClient is server-side event handle
func (es *eventServer) Handler(w http.ResponseWriter, r *http.Request) {
	f, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "ES Handler: Streaming unsupported!", http.StatusInternalServerError)
		return
	}

	clientID := r.Header.Get(headerNameClientID)
	if clientID == "" {
		log.Println("ES Handler: Missing client-id")
		data := serverEventData{
			Action: actionError,
			Params: map[string]string{
				"message": "header " + headerNameClientID + " is missing",
			},
			TS: time.Now().Unix(),
		}
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		json.NewEncoder(w).Encode(data)
		return
	}

	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")
	w.Header().Set("Transfer-Encoding", "chunked")

	messageChan := make(chan []byte)
	clientChan := eventServerClient{
		channel:  messageChan,
		clientID: clientID,
	}

	log.Println("ES Handler: New client connected.")
	es.newClient <- clientChan

	// get notified when client is closed.
	notify := w.(http.CloseNotifier).CloseNotify()
	go func() {
		<-notify
		es.closingClient <- clientChan
		log.Println("ES Handler: Client disconnected.")
	}()

	for {
		msg, open := <-messageChan
		if !open {
			break
		}
		fmt.Fprintf(w, "%s\n\n", msg)
		f.Flush()
	}
	log.Println("ES Handler: Server closed client connection.")
}

func (es *eventServer) route(r *mux.Router) {
	r.HandleFunc("/events", es.Handler).Methods("GET")
}

func (es *eventServer) KeepAlive() {
	log.Println("ES Keep-alive is on.")
	var live = true
	go func() {
		<-es.kldone
		live = false
	}()

	for live {
		ret := es.sendEvent(clientNobody, actionKeepalive, nil)
		if ret {
			log.Println("ES Keep-alive: Sent")
		}
		time.Sleep(keepAliveInterval)
	}
	log.Println("ES Keep-alive is closed")
}

// main loop
func (es *eventServer) MainLoop() {
	go func() {
		var alive = true
		for alive {
			select {
			case s := <-es.newClient:
				{
					es.clients[s.clientID] = s.channel
					log.Println("ES Main: Client connected.")
					es.sendWelcome(s.channel)
				}
			case s := <-es.closingClient:
				{
					delete(es.clients, s.clientID)
					close(s.channel)
					log.Println("ES Main: Client disconnected.")
				}
			case pack, open := <-es.message:
				{
					if open {
						var cnt = 0
						msg, err := json.Marshal(pack.data)
						if err == nil {
							for clientID, channel := range es.clients {
								// TODO: check the client id one by one
								if pack.clientID != clientID {
									channel <- msg
									cnt++
								}
							}
						}
						log.Printf("ES Main: Broadcast %d/%d clients\n", cnt, len(es.clients))
					} else {
						log.Println("ES Main: Server is closing, notify clients...")
						for clientID, channel := range es.clients {
							close(channel)
							delete(es.clients, clientID)
						}
						es.message = nil
						es.done <- true
						// out of loop
						alive = false
					}
				}
			}
		}
		log.Println("ES Main: End")
	}()
}

func (es *eventServer) Notify(clientID string, params *map[string]string) {
	ret := es.sendEvent(clientID, actionNotify, params)
	if ret != false {
		log.Println("ES Notify: Sent")
	}
}

func (es *eventServer) End() {
	log.Printf("Shutting down event server...")

	// stop keepalive
	es.kldone <- true

	// send all client to close
	es.sendEvent(clientNobody, actionClose, nil)

	// close message
	close(es.message)

	// wait until dispatcher is done
	<-es.done
	log.Println("Shutting down event server is done")
}
