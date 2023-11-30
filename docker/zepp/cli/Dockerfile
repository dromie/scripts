#target: zeus-cli
FROM node:20-bookworm
RUN npm i @zeppos/zeus-cli -g
RUN apt-get update && apt-get install -y firefox-esr
ENTRYPOINT ["zeus"]
