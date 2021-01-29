#!/bin/sh

# mkdir -p ../macos/Runner/Backend
go build -o libBackend.a -buildmode=c-archive
cp libBackend.a libBackend.h ../macos/Runner/Backend
rm libBackend.a libBackend.h