#!/bin/bash
set -ex
go get github.com/go-ble/ble/examples/lib/dev github.com/mgutz/logxi/v1 github.com/peterhellberg/ruuvitag
GOOS=linux GOARCH=arm go build -ldflags="-s -w" -o ruuvipush ruuvipush.go
#go build -ldflags="-s -w" -o ruuvipush.native ruuvipush.go
