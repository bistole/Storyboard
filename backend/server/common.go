package server

import (
	"net/http"
	"strconv"
)

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
