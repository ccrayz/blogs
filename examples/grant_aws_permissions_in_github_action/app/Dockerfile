FROM golang:1.22.3-alpine AS builder
WORKDIR /app
COPY go.mod go.sum main.go ./
RUN go mod download
RUN go build -o server .

FROM alpine:latest
COPY --from=builder /app/server .
ENTRYPOINT ["./server"]