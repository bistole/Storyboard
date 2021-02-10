package server

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"regexp"
	"strconv"
	"time"
)

const headerNameClientID = "client-id"

const notifyTypePhoto = "photo"
const notifyTypeTask = "task"

// GetOutboundIP get most possible ip address to bind
func GetOutboundIP() string {
	conn, err := net.Dial("udp", "8.8.8.8:80")
	if err != nil {
		panic(err)
	}
	defer conn.Close()

	localIP := conn.LocalAddr().(*net.UDPAddr).IP.String()
	log.Println("Outbound IP: " + localIP)
	return localIP
}

// GetServerIPs get candidates of ip address
func GetServerIPs() map[string]string {
	ifaces, err := net.Interfaces()
	if err != nil {
		panic(err)
	}

	var results map[string]string = make(map[string]string)
	for _, i := range ifaces {
		addrs, err := i.Addrs()
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

// ConvertQueryParamToInt get url query
func ConvertQueryParamToInt(r *http.Request, key string, def int) int {
	rawVal, ok := r.URL.Query()[key]
	if !ok || len(rawVal[0]) < 1 {
		return def
	}
	val, err := strconv.Atoi(rawVal[0])
	if err != nil {
		return def
	}
	return val
}

// IsStringUUID check if string is uuid
func IsStringUUID(uuid string, errMsg string) error {
	r := regexp.MustCompile("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-4[a-fA-F0-9]{3}-[8|9|aA|bB][a-fA-F0-9]{3}-[a-fA-F0-9]{12}$")
	if r.MatchString(uuid) {
		return nil
	}
	return fmt.Errorf(errMsg)
}

// IsStringNotEmpty check if string is uuid
func IsStringNotEmpty(content string, errMsg string) error {
	if len(content) > 0 {
		return nil
	}
	return fmt.Errorf(errMsg)
}

const beforeTS = 86400 * 365 // a year
const afterTS = 86400 * 1    // a month

// IsIntValidDate check if number is timestamp
func IsIntValidDate(date int64, errMsg string) error {
	cur := time.Now().Unix()
	if date > cur-beforeTS && date < cur+afterTS {
		return nil
	}
	return fmt.Errorf(errMsg)
}
