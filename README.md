# Storyboard


Environment
===========

export PATH=$HOME/Flutter/flutter/bin:/usr/local/go/bin:$HOME/go/bin:$PATH

export CGO_ENABLED=1

Run
===

hover run

UI Test
=======

SINGLE TEST
-----------

flutter test [file]

COVERAGE
--------

flutter test --coverage
/usr/local/bin/genhtml coverage/lcov.info -o coverage/html


BACKEND Test
============

SINGLE TEST
-----------

cd $PROJECT_HOME/backend
go test [file]

> The file should start with ./

COVERAGE
--------

cd $PROJECT_HOME/backend
go test ./... -coverprofile=coverage.out
go tool cover -html=coverage.out