FROM ibmcom/swift-ubuntu:4.0

RUN mkdir /www
RUN /bin/bash -c "$(wget -qO- https://apt.vapor.sh)"
RUN apt-get install ctls
RUN apt-get install postgresql postgresql-contrib libpq-dev -y

WORKDIR /www
COPY Package.swift .
COPY Package.pins .
COPY Sources Sources

RUN swift build -c release -Xswiftc -O

COPY Config Config
COPY Resources Resources
COPY Public Public

EXPOSE 8080

ENTRYPOINT [".build/release/Run"]
