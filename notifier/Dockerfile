FROM golang:1.15-alpine AS builder

WORKDIR /app

COPY go.mod ./
COPY go.sum ./

RUN go mod download

COPY *.go ./

RUN env CGO_ENABLED=0 go build -o /app/notifier

FROM scratch

COPY --from=builder /app/notifier /go/bin/notifier

ENTRYPOINT ["/go/bin/notifier"]
