# target: hamachi
FROM ubuntu:18.04
RUN apt-get update && apt-get update && apt-get install -y wget iproute2 inetutils-ping dnsutils && apt-get clean
RUN mkdir /tmp/hamachi && wget https://www.vpn.net/linux -O -|grep -o 'href="[^"]*x64.tgz'|cut -f 2 -d'"'|xargs -I{} wget https://www.vpn.net{} -O -|tar xvz -C /tmp/hamachi  --strip-components 1
WORKDIR /tmp/hamachi
RUN /tmp/hamachi/install.sh
