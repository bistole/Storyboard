module Storyboard/go

go 1.15

replace Storyboard/backend => ../backend

require (
	Storyboard/backend v0.0.0
	github.com/go-flutter-desktop/go-flutter v0.42.0
	github.com/go-flutter-desktop/plugins/path_provider v0.4.0
	github.com/mattn/go-sqlite3 v1.14.5 // indirect
	github.com/pkg/errors v0.9.1
)
