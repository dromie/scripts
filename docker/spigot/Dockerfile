#target: spigot
FROM eclipse-temurin:17-jdk-jammy as builder
RUN apt-get update && apt-get install -y git
RUN mkdir /src && curl -Lo /src/BuildTools.jar "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
WORKDIR /src
RUN java -jar BuildTools.jar --rev 1.20.3

FROM eclipse-temurin:17-jdk-jammy as spigot
RUN mkdir -p /usr/minecraft/worlds
RUN mkdir -p /usr/minecraft/plugins
WORKDIR /usr/minecraft
COPY --from=builder /src/spigot*.jar /usr/minecraft/spigot.jar
RUN curl -Lo /usr/minecraft/plugins/Geyser-Spigot.jar "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
RUN curl -Lo /usr/minecraft/plugins/floodgate-spigot.jar "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot"
CMD java -Dcom.mojang.eula.agree=true -jar spigot.jar --nogui -P /usr/minecraft/plugins -W /usr/minecraft/worlds
