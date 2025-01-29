# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_FROM
FROM $BUILD_FROM

# renovate: depName=waterfurnace_aurora datasource=rubygems
ENV VERSION=1.4.11

# Execute during the build of the image
ARG TEMPIO_VERSION BUILD_ARCH

RUN \
    apk add --no-cache --virtual=.build-deps \
        ruby-dev \
        build-base

RUN \
    apk add --no-cache ca-certificates openssl ruby ruby-ffi && \
    gem install waterfurnace_aurora -v ${VERSION}

RUN apk del --purge .build-deps

ENV TTY=/dev/serial/by-id/usb-FTDI_FT232R_USB_UART_AB0LICHU-if00-port0
ENV MQTT=mqtt://localhost

# Copy root filesystem
COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

CMD [ "/entrypoint.sh" ]
