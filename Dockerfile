ARG ALPINE_VERSION=3.18
FROM alpine:${ALPINE_VERSION} as prod

ARG VIRTUAL_PIP_INSTALL_DEPS=pip-install-deps
RUN apk update && \
    apk add --no-cache \
        gcompat \
        python3 \
        bash \
        py3-pip \
        tzdata && \
    apk add --no-cache --virtual "${VIRTUAL_PIP_INSTALL_DEPS}" \
        gcc \
        build-base \
        musl-dev \
        python3-dev

RUN mkdir -p /app
WORKDIR /app
COPY . ${WORKDIR}
EXPOSE 3000


WORKDIR    /opt/oracle

RUN apk update && apk add libaio wget unzip 
RUN wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip  && \ 
    unzip instantclient-basiclite-linuxx64.zip && \
    rm -f instantclient-basiclite-linuxx64.zip && \
    mv /opt/oracle/instantclient* /opt/oracle/instantclient 

WORKDIR /opt/oracle/instantclient
RUN rm -f *jdbc* *occi* *mysql* *README *jar uidrvci genezi adrci 
RUN mkdir -p /etc/ld.so.conf.d 
RUN echo /opt/oracle/instantclient* > /etc/ld.so.conf.d/oracle-instantclient.conf 
RUN ln -s /opt/oracle/instantclient /opt/oracle/instantclient/lib

ENV LD_LIBRARY_PATH /opt/oracle/instantclient
ENV ORACLE_HOME /opt/oracle/instantclient

ENV PATH $PATH:/opt/oracle/instantclient
WORKDIR /app

RUN pip install --upgrade pip && \
    pip install poetry && \
    python3 -m poetry config virtualenvs.in-project true && \
    python3 -m poetry install


#RUN pip install fastapi uvicorn
#RUN pip install cx_Oracle
#RUN pip install pytz

#RUN mkdir -p /app 
#WORKDIR /app

#COPY . ${WORKDIR}

RUN apk --purge del "${VIRTUAL_PIP_INSTALL_DEPS}"
ENV SERVER_PORT 3000
#ENTRYPOINT python3 -m poetry run uvicorn main:app --host  "0.0.0.0:${SERVER_PORT}"
CMD python3 -m poetry run uvicorn main:app --host=0.0.0.0 --reload --port ${SERVER_PORT}
#CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
#MD ["uvicorn", "main:app", "--host=0.0.0.0" , "--reload" , "--port", "8000"]
