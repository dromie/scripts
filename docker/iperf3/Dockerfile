#target: iperf3

FROM build-essential as builder
ARG IPERF3_VERSION=3.7
WORKDIR /src
RUN wget https://github.com/esnet/iperf/archive/${IPERF3_VERSION}.tar.gz -O /src/iperf.tar.gz
RUN tar xzf iperf.tar.gz && cd iperf* && ./configure --prefix=/opt && make && make install

FROM ubuntu:18.04
COPY --from=builder /opt /opt
ENTRYPOINT ["/opt/bin/iperf3"]
