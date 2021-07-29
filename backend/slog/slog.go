package slog

import (
	"fmt"
	"io"
	"log"
	"os"
	"path"
	"time"
)

type SLog struct {
	logLocation string
	buffer      []string
	handle      *io.WriteCloser
}

var slog SLog = SLog{buffer: make([]string, 0), handle: nil, logLocation: ""}

func (l *SLog) setPath(appLocation string) {
	newLogFolder := path.Join(appLocation, "logs")

	ts := time.Now().Format("2006-01-02")
	newLogLocation := path.Join(newLogFolder, "backend-"+ts+".log")

	if newLogLocation != l.logLocation {
		l.logLocation = newLogLocation

		// close old one if exists
		if l.handle != nil {
			(*l.handle).Close()
		}

		// create folder if not exist
		_, err := os.Stat(newLogFolder)
		if os.IsNotExist(err) {
			os.MkdirAll(newLogFolder, 0755)
		}

		f, err := os.Create(newLogLocation)
		if err != nil {
			panic("Failed to create log file: " + newLogLocation)
		}
		log.Println("Log file created: ", newLogLocation)
		var writer io.WriteCloser = f
		l.handle = &writer

		// write buffer to log file
		if len(l.buffer) > 0 {
			for _, line := range l.buffer {
				fmt.Fprint(*(l.handle), line)
			}
			l.buffer = make([]string, 0)
		}
	}
}

func (l *SLog) writeToFile(level string, message string) {
	ts := time.Now().Format("2006-01-02 15:04:05")
	if l.handle != nil {
		fmt.Fprintf(*(l.handle), "%s %s %s", ts, level, message)
	} else {
		l.buffer = append(l.buffer, fmt.Sprintf("%s %s %s", ts, level, message))
	}
}

func (l *SLog) Printf(level string, format string, args ...interface{}) {
	mesg := fmt.Sprintf(format, args...)
	l.writeToFile(level, mesg)
}

func (l *SLog) Println(level string, args ...interface{}) {
	mesg := fmt.Sprintln(args...)
	l.writeToFile(level, mesg)
}

func Printf(format string, args ...interface{}) {
	slog.Printf("INFO", format, args...)
	log.Printf(format, args...)
}

func Println(args ...interface{}) {
	slog.Println("INFO", args...)
	log.Println(args...)
}

func Fatalf(format string, args ...interface{}) {
	slog.Printf("FATAL", format, args...)
	log.Fatalf(format, args...)
}

func Fatalln(args ...interface{}) {
	slog.Println("FATAL", args...)
	log.Fatalln(args...)
}

func SetPath(path string) {
	slog.setPath(path)
}
