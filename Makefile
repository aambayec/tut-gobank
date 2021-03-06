dockerstart:
	docker start postgres13

mockdb:
	mockgen -package mockdb -destination db/mock/store.go github.com/aambayec/tut-gobank/db/sqlc Store

postgres:
	docker run --name postgres13 --network simplebank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=Ulyanin123 -d postgres:12-alpine

createdb:
	docker exec -it postgres13 createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres13 dropdb simple_bank

migrateup:
	migrate -path db/migration -database "postgresql://root:Ulyanin123@localhost:5432/simple_bank?sslmode=disable" -verbose up

migrateup1:
	migrate -path db/migration -database "postgresql://root:Ulyanin123@localhost:5432/simple_bank?sslmode=disable" -verbose up 1

migratedown:
	migrate -path db/migration -database "postgresql://root:Ulyanin123@localhost:5432/simple_bank?sslmode=disable" -verbose down

migratedown1:
	migrate -path db/migration -database "postgresql://root:Ulyanin123@localhost:5432/simple_bank?sslmode=disable" -verbose down 1

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

server:
	go run main.go

.PHONY: createdb createdb dropdb migrateup migratedown sqlc test server mockdb migrateup1 migratedown1

