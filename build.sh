#!/bin/bash
set -ex
go get -u github.com/go-ble/ble
go get -u github.com/mgutz/logxi/v1
go get -u github.com/peterhellberg/ruuvitag
GOOS=linux GOARCH=arm go build -ldflags="-s -w" -o ruuvipush ruuvipush.go
#go build -ldflags="-s -w" -o ruuvipush.native ruuvipush.go
