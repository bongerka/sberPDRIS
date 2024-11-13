FROM golang:1.22.0 as gobuild

WORKDIR /app

COPY . .
RUN go mod download
RUN go build -o main ./cmd/pdris

CMD [ "./main"]