package main

import (
	"context"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"strconv"

	"github.com/go-ble/ble"
	"github.com/go-ble/ble/examples/lib/dev"
	"github.com/peterhellberg/ruuvitag"
)

var apiurl = "nonsense"

func setup(ctx context.Context) context.Context {
	d, err := dev.DefaultDevice()
	if err != nil {
		panic(err)
	}
	ble.SetDefaultDevice(d)

	return ble.WithSigHandler(context.WithCancel(ctx))
}

func main() {
	if len(os.Args[1:]) >= 1 {
		apiurl = os.Args[1]
	} else {
		fmt.Printf("Usage: $0 <apiurl>\n")
		os.Exit(1)
	}

	ctx := setup(context.Background())

	ble.Scan(ctx, true, handler, filter)
}

func handler(a ble.Advertisement) {
	raw, err := ruuvitag.ParseRAWv1(a.ManufacturerData())
	if err == nil {
		// fmt.Printf("[%s] RSSI: %3d: %+v\n", a.Addr(), a.RSSI(), raw)
		resp, err := http.PostForm(apiurl, url.Values{
			"id":          {a.Addr().String()},
			"temperature": {strconv.FormatFloat(raw.Temperature, 'f', 6, 64)}})

		if err != nil {
			fmt.Printf("Failed to post: %v\n", err)
		} else {
			resp.Body.Close()
		}
	}
}

func filter(a ble.Advertisement) bool {
	return ruuvitag.IsRAWv1(a.ManufacturerData())
}
