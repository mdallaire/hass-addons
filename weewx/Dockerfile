# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_FROM
FROM $BUILD_FROM


# renovate: datasource=pypi packageName=weewx
ENV VERSION=5.2.0

# Execute during the build of the image
ARG TEMPIO_VERSION BUILD_ARCH
ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    HOME="/addon_config"
RUN \
    apk add --no-cache \
        py3-pip \
        bash \
        gcc \
        unzip

RUN \
    pip install weewx==${VERSION} \
    && \
    pip install \
        paho-mqtt \
        #python-cjson \
        ujson \
        ephem \
        urllib3 \
        influxdb

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD [ "/entrypoint.sh" ]
