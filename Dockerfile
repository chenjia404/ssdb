FROM alpine:3 as builder

RUN apk update && \
    apk add gcc  && \
    apk add --virtual .build-deps autoconf make g++ git


COPY . /usr/src/ssdb/
RUN make  -C /usr/src/ssdb && \
  make -C /usr/src/ssdb install


FROM alpine:3
RUN  apk add gcc
COPY --from=builder  /usr/local/ssdb /usr/local/ssdb

RUN sed \
    -e 's@ip:.*@ip: 0.0.0.0@' \
    -e 's@cache_size:.*@cache_size: 4096@' \
    -e 's@write_buffer_size:.*@write_buffer_size: 512@' \
    -e 's@level:.*@level: info@' \
    -e 's@output:.*@output:@' \
    -i /usr/local/ssdb/ssdb.conf

EXPOSE 8888
VOLUME /usr/local/ssdb/var/data
VOLUME /usr/local/ssdb/var/meta
WORKDIR /usr/local/ssdb/

ENTRYPOINT rm -f /usr/local/ssdb/var/ssdb.pid && /usr/local/ssdb/ssdb-server /usr/local/ssdb/ssdb.conf