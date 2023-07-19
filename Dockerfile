ARG ALPINE_VERSION=3.18
FROM alpine:${ALPINE_VERSION} as prod

ARG VIRTUAL_PIP_INSTALL_DEPS=pip-install-deps
RUN apk update && \
    apk add --no-cache \
        python3 \
        py3-pip && \
    apk add --no-cache --virtual "${VIRTUAL_PIP_INSTALL_DEPS}" \
        gcc \
        build-base \
        musl-dev \
        python3-dev

# python3 -m poetry install --no-dev
RUN pip install --upgrade pip && \
    pip install poetry && \
    python3 -m poetry config virtualenvs.in-project true && \
    python3 -m poetry install 

RUN mkdir -p /app 
WORKDIR /app
COPY . ${WORKDIR}

RUN apk --purge del "${VIRTUAL_PIP_INSTALL_DEPS}"
ENV SERVER_PORT 8080
ENTRYPOINT python3 -m poetry run uvicorn main:app --reload -w 1 -b "0.0.0.0:${SERVER_PORT}"
