FROM golang:1.15-alpine AS builder

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
COPY conf.yml ./

RUN go mod download

COPY *.go ./

RUN env CGO_ENABLED=0 go build -o /app/processor

FROM scratch

WORKDIR /go/bin

COPY --from=builder /app/processor /go/bin/processor
COPY --from=builder /app/conf.yml /go/bin/conf.yml

ENTRYPOINT ["/go/bin/processor"]
