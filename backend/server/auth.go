package server

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/mux"
)

// Ping to check server status
func (rs RESTServer) Ping(w http.ResponseWriter, r *http.Request) {
	type Succ struct {
		Pong bool `json:"pong"`
	}
	var response Succ
	response.Pong = true
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

type eventServer struct {
	clients       map[chan []byte]bool
	newClient     chan chan []byte
	closingClient chan chan []byte
	message       chan []byte
	kldone        chan bool
	done          chan bool
}

type eventServerPack struct {
	Action string            `json:"action"`
	Params map[string]string `json:"params"`
	TS     int64             `json:"ts"`
}

// EventClient is server-side event handle
func (es *eventServer) Handler(w http.ResponseWriter, r *http.Request) {
	f, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "HTTP: Streaming unsupported!", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")
	w.Header().Set("Transfer-Encoding", "chunked")

	messageChan := make(chan []byte)
	log.Println("ES HTTP: New client connected.")
	es.newClient <- messageChan

	// get notified when client is closed.
	notify := w.(http.CloseNotifier).CloseNotify()
	go func() {
		<-notify
		es.closingClient <- messageChan
		log.Println("ES HTTP: Client disconnected.")
	}()

	for {
		msg, open := <-messageChan
		if !open {
			break
		}
		fmt.Fprintf(w, "%s\n\n", msg)
		f.Flush()
	}
	log.Println("ES HTTP: Server closed client connection.")
}

// EventServerStart start server side event
func (es *eventServer) Start(r *mux.Router) {
	r.HandleFunc("/events", es.Handler).Methods("GET")

	// keepalive
	go func() {
		var live = true
		go func() {
			<-es.kldone
			live = false
		}()

		for live {
			Pack := eventServerPack{
				Action: "alive",
				Params: make(map[string]string),
				TS:     time.Now().Unix(),
			}
			msg, err := json.Marshal(Pack)
			if err != nil {
				continue
			}

			if live {
				log.Println("ES ALIVE: Sent")
				es.message <- msg
				time.Sleep(time.Second * 5)
			}
		}
		log.Println("ES ALIVE: End")
	}()

	// main loop
	go func() {
		var alive = true
		for alive {
			select {
			case s := <-es.newClient:
				{
					es.clients[s] = true
					log.Println("ES SERVER: Client connected.")
				}
			case s := <-es.closingClient:
				{
					delete(es.clients, s)
					close(s)
					log.Println("ES SERVER: Client disconnected.")
				}
			case msg, open := <-es.message:
				{
					if open {
						for s := range es.clients {
							s <- msg
						}
						log.Printf("ES SERVER: Broadcast %d clients\n", len(es.clients))
					} else {
						log.Println("ES SERVER: Server is closing, notify clients...")
						for s := range es.clients {
							close(s)
						}
						es.done <- true
						// out of loop
						alive = false
					}
				}
			}
		}
		log.Println("ES SERVER: End")
	}()
}

func (es *eventServer) Notify(action string, params map[string]string) {
	Pack := eventServerPack{
		Action: action,
		Params: params,
		TS:     time.Now().Unix(),
	}
	msg, err := json.Marshal(Pack)
	if err != nil {
		return
	}
	log.Println("ES NOTIFY: Sent")
	es.message <- msg
}

func (es *eventServer) End() {
	log.Printf("ES END: Start")
	Pack := eventServerPack{
		Action: "closed",
		Params: make(map[string]string),
		TS:     time.Now().Unix(),
	}
	msg, err := json.Marshal(Pack)
	if err != nil {
		return
	}
	log.Printf("ES END: Sent")
	es.message <- msg
	log.Println("ES END: Close")
	close(es.message)

	<-es.done
	log.Println("ES END: End")
}
