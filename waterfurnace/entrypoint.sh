#!/usr/bin/with-contenv bashio

export MQTT=$(bashio::config 'mqtt')
export TTY=$(bashio::config 'tty')

# Try Hassio MQTT Auto-Configuration
if ! bashio::services.available "mqtt" && ! bashio::config.exists 'mqtt_server'; then
    bashio::exit.nok "No internal MQTT service found and no MQTT server defined. Please install Mosquitto broker or specify your own."
else
    bashio::log.info "MQTT available, fetching server detail ..."
    if ! bashio::config.exists 'mqtt'; then
        bashio::log.info "MQTT server settings not configured, trying to auto-discovering ..."
        export MQTT_HOST=$(bashio::services mqtt "host")
        export MQTT_PORT=$(bashio::services mqtt "port")
        bashio::log.info "Configuring '$MQTT_HOST' mqtt server"
        export MQTT_USERNAME=$(bashio::services mqtt "username")
        export MQTT_PASSWORD=$(bashio::services mqtt "password")
        bashio::log.info "Configuring '$MQTT_USERNAME' mqtt user"
        export MQTT="mqtt://$MQTT_USERNAME:$MQTT_PASSWORD@$MQTT_HOST:$MQTT_PORT"
    fi
fi

ruby aurora_mqtt_bridge $TTY $MQTT
