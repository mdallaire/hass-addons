# Home Assistant Add-on: Weewx

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

This is a very basic Weewx add-on. For now it does not include any USB devices since my station is over IP connection. I might add options for it down the road.

Right now it checks if there is an existing configuration `/addon_config/weewx-data` and if not it creates one. If there is an existing configuration the addon starts using the weewx.conf file.


