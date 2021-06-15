# tut-gobank

Tech School Backend master class [Golang, Postgres, Docker]

# Setting up

1. [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. [Docker Postgres](https://hub.docker.com/_/postgres/)

```shell
docker run --name postgres13 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=Ulyanin123 -d postgres:12-alpine
docker exec -it postgres13 createdb --username=root --owner=root simple_bank
```

3. Golang and libraries
   - [Golang Migrate](https://github.com/golang-migrate)

Linux Install

```
curl -L https://github.com/golang-migrate/migrate/releases/download/v4.14.1/migrate.linux-amd64.tar.gz | tar xvz
sudo mv migrate.linux-amd64 /usr/bin/
which migrate
```

Mac Install

```
brew install golang-migrate
```

Setup

```shell
mkdir -p db/migration
migrate create -ext sql -dir db/migration -seq init_schema
migrate -path db/migration -database "postgresql://root:Ulyanin123@localhost:5432/simple_bank?sslmode=disable" -verbose up
```

Creating new migration

```
migrate create -ext sql -dir db/migration -seq add_users
```

- [Viper](https://github.com/spf13/viper)

```
go get github.com/spf13/viper
```

- [Mockgen](https://github.com/golang/mock)

```
go get github.com/golang/mock/mockgen@v1.5.0
mockgen --version
```

4. [SQLC](https://sqlc.dev/)

- Download SQLC.

```shell
sudo apt update && sudo apt -y upgrade
wget -c https://github.com/kyleconroy/sqlc/releases/download/v1.8.0/sqlc-v1.8.0-linux-amd64.tar.gz -O - | tar -xz
```

Move the downloaded file to a directory enabled in \$Path i.e. $GOPATH/bin.

- Initilize SQLC

```
sqlc init
```

It will create sqlc.yaml file, configure as you like. Then:

```
sqlc generate
```

5. [Golang Postgres Library PQ](https://github.com/lib/pq)

```
go get github.com/lib/pq
```

# Tools

## Entity-Relationship Diagrams

[dbdiagram](https://dbdiagram.io/home)

# Docker Commands Guide

```shell
docker build --help

# downloading docker image from store
docker pull postgres:12-alpine

# building image from local
docker build -t simplebank:latest .

# to list all images
docker images

# to remove old image
docker rmi 23cec85a1a89

# to run and create image and container with IP Address
docker run --name simplebank -p 8080:8080 -e DB_SOURCE="postgresql://root:Ulyanin123@172.17.0.2:5432/simple_bank?sslmode=disable" -e GIN_MODE=release simplebank:latest

# to run and create image and container with network name
docker run --name simplebank --network simplebank-network -p 8080:8080 -e DB_SOURCE="postgresql://root:Ulyanin123@postgres13:5432/simple_bank?sslmode=disable" -e GIN_MODE=release simplebank:latest

# to start existing container
docker start simplebank

# to stop existing container
docker stop simplebank

# to check containers status
docker ps -a

# to remove container by name
docker rm simplebank

# to inspect container details e.g. Networks IP address
docker container inspect postgres13

# to see network details
docker network ls
docker network inspect bridge

# to create a new network
docker network --help
docker network create simplebank-network

# to connect your container to a specific network
docker network connect --help
docker network connect simplebank-network postgres13
docker network inspect simplebank-network
docker inspect postgres13

# executing commands inside container as root user with selected database
docker exec -it postgres13 psql -U root simple_bank
\q

# executing commands inside container as root user
docker exec -it postgres13 psql -U root

# executing commands inside container using bash shell
docker exec -it postgres13 /bin/sh
createdb --username=root --owner=root simple_bank
psql simple_bank
\q
dropdb simple_bank
exit

# executing commands in container directly in shell
docker exec -it postgres13 createdb --username=root --owner=root simple_bank
```

# DEVELOPMENT Steps

1. Migration

Create the folder where you want to put your migration files. E.g. _db/migration_

```shell
mkdir -p db/migration
```

Create a new instance of your migration. E.g. _init_schema_, _add_users_
This will create an _up_ and _down_ version file in your migration folder.
Edit them to create and delete the DB objects.

```shell
migrate create -ext sql -dir db/migration -seq init_schema
```

Run migration up or down, set your connection string.

```shell
migrate -path db/migration -database "postgresql://root:Ulyanin123@localhost:5432/simple_bank?sslmode=disable" -verbose up

migrate -path db/migration -database "postgresql://root:Ulyanin123@localhost:5432/simple_bank?sslmode=disable" -verbose down
```

2. SQLC - to autogenerate creation of Golang objects.

Initilize SQLC, It will create _sqlc.yaml_ file.

```
sqlc init
```

Configure your sqlc.yaml. E.g:

```yaml
version: "1"
packages:
  - name: "db"
    path: "./db/sqlc"
    queries: "./db/query/"
    schema: "./db/migration/"
    engine: "postgresql"
    emit_json_tags: true
    emit_prepared_queries: false
    emit_interface: true
    emit_exact_table_names: false
    emit_empty_slices: true
    json_tags_case_style: "camel"
```

Generate SQLC, it will create Golang objects based on the files in your _migration_ and _queries_ folder.

```
sqlc generate
```

3. Mock db

For testing purpose, this will create a mockversion of your db.

```
mockgen -package mockdb -destination db/mock/store.go github.com/aambayec/tut-gobank/db/sqlc Store
```

# DEPLOYMENT

1. Create _Dockerfile_ then edit in the root folder

```Dockerfile
# Build stage
FROM golang:1.16.5-alpine3.13 AS builder
WORKDIR /app
COPY . .
RUN go build -o main main.go
RUN apk --no-cache add curl
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.14.1/migrate.linux-amd64.tar.gz | tar xvz

# Run stage
FROM alpine:3.13
WORKDIR /app
COPY --from=builder /app/main .
COPY --from=builder /app/migrate.linux-amd64 ./migrate
COPY app.env .
COPY start.sh .
COPY wait-for.sh .
COPY db/migration ./migration

EXPOSE 8080
CMD [ "/app/main" ]
ENTRYPOINT [ "/app/start.sh" ]
```

2. Create _docker-compose.yaml_ in the root folder

```yaml
version: "3.9"
services:
  postgres:
    image: postgres:12-alpine
    environment:
      - POSTGRES_USER=root
      - POSTGRES_PASSWORD=Ulyanin123
      - POSTGRES_DB=simple_bank
  api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      - DB_SOURCE=postgresql://root:Ulyanin123@postgres:5432/simple_bank?sslmode=disable
    depends_on:
      - postgres
    entrypoint: ["/app/wait-for.sh", "postgres:5432", "--", "/app/start.sh"]
    command: ["/app/main"]
```

Run.

```
docker compose up
```

2. Create _start.sh_ in the root directory.

```sh
#!/bin/sh

set -e

echo "run db migration"
/app/migrate -path /app/migration -database "$DB_SOURCE" -verbose up

echo "start the app"
exec "$@"
```

Make _start.sh_ executable

```shell
chmod +x start.sh
```

Download the [wait-for](https://github.com/Eficode/wait-for) latest release then rename to _wait-for.sh_, move the the root folder
Make _wait-for.sh_ executable

```shell
chmod +x _wait-for.sh
```

Run

```
docker compose up
```
