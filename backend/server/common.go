package server

import (
	"fmt"
	"net/http"
	"regexp"
	"strconv"
	"time"
)

const headerNameClientID = "client-id"

const notifyTypePhoto = "photo"
const notifyTypeNote = "note"

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

func IsIntValidDirection(direction int32, errMsg string) error {
	if direction != 0 && direction != 90 && direction != 180 && direction != 270 {
		return fmt.Errorf(errMsg)
	}
	return nil
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
