#target: dropbear
FROM alpine:3.14
RUN adduser -D sleeper
RUN apk add --no-cache dropbear wireguard-tools-wg-quick wireguard-tools
COPY dropbear_*_host_key /etc/dropbear/
COPY getconsole /bin/
COPY checkconsoles /bin/
RUN mkdir /home/sleeper/.ssh
COPY authorized_keys /home/sleeper/.ssh/
COPY sleeper_console* /home/sleeper/
COPY console /home/sleeper/
RUN chown -R sleeper:sleeper /home/sleeper
COPY startup.sh /startup.sh
CMD /startup.sh
