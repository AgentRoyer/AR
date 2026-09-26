FROM golang:1.21-alpine as builder
WORKDIR /app
COPY . ./
RUN go build -o app-go .
FROM alpine:latest
RUN apk add --no-cache ca-certificates curl
WORKDIR /app
COPY --from=builder /app/app-go /app/
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD curl -f http://localhost:8080/health || exit 1
CMD ["./app-go"]
