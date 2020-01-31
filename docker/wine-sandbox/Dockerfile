#target: wine-sandbox

FROM build-essential
RUN dpkg --add-architecture i386 && apt-get update
RUN apt-get install -y wine-stable winetricks wine32
