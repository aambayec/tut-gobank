# tut-gobank

Tech School Backend master class [Golang, Postgres, Docker]

# Setting up

1. [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. [Docker Postgres](https://hub.docker.com/_/postgres/)

```shell
docker run --name postgres13 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=Ulyanin123 -d postgres:13-alpine
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

# Docker Commands

```shell
docker ps
docker images
docker stop postgres13
docker ps -a
docker rm postgres13
docker start postgres13
docker exec -it postgres13 psql -U root
docker exec -it postgres13 /bin/sh
exit
```

```shell
docker pull postgres:13-alpine
docker run --name postgres13 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=Ulyanin123 -d postgres:13-alpine

docker exec -it postgres13 /bin/sh
createdb --username=root --owner=root simple_bank
psql simple_bank
\q
dropdb simple_bank
exit

docker exec -it postgres13 createdb --username=root --owner=root simple_bank
docker exec -it postgres13 psql -U root simple_bank
\q
```

```
docker start postgres13
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
