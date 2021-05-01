# RuuviTag to HTTP server

This repository hosts two binaries that take care of converting
BLE announcements from RuuviTags to HTTP dashboard with temperatures.

Roughly like so:

```
ruuvi ---[ble]---> ruuvipush ---[http]---> temperatures.rb
```

This dashboard is then queried by esp32-to-433MHz firmware to push
it to our old clunky digital clock.

More information can be found in the [Putting an old digital clock (with an
outdoor thermometer) on steroids](https://wejn.org/2021/05/putting-old-temp-clock-on-steroids/)
article.

## Contents

* `temperatures.rb` is the webserver
* `ruuvipush.go` is the ble-to-http collector
* `build.sh` highly sophisticated build script for the ruuvipush
* `etc_service` daemontools service definitions

## Credits

* Author: Michal Jirku (wejn.org)
* License: GPL v2, unless stated otherwise in the file

