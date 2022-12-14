FROM alpine/git
WORKDIR /app
RUN git clone https://github.com/lorenzopetra96/sudoku-game.git

FROM maven:3.5-jdk-8-alpine
WORKDIR /app
COPY --from=0 /app/sudoku-game /app
RUN mvn package

FROM openjdk:8-jre-alpine
WORKDIR /app
ENV MASTERIP=172.20.128.0
ENV ID=0
COPY --from=1 /app/target/sudoku-game-1.0-jar-with-dependencies.jar /app

CMD /usr/bin/java -jar sudoku-game-1.0-jar-with-dependencies.jar -m $MASTERIP -id $ID