# tut-gobank

Tech School Backend master class [Golang, Postgres, Docker]

# Create Entity-Relationship Diagrams

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

# Migration

```
mkdir -p db/migration
migrate create -ext sql -dir db/migration -seq init_schema
```
