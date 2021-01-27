#!/bin/sh

cd ../backend
go build -o libBackend.a -buildmode=c-archive
mv libBackend.a libBackend.h ../c
cd ../c
clang -I. -o main main.cpp libBackend.a -framework CoreFoundation -framework Security