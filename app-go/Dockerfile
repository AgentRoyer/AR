FROM golang:1.21-alpine as builder
WORKDIR /build
COPY ./Projects ./
RUN cd chatbot && go build -o /build/app-go .
FROM alpine:latest
RUN apk add --no-cache ca-certificates curl
WORKDIR /app
COPY --from=builder /build/app-go /app/
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD curl -f http://localhost:8080/health || exit 1
CMD ["./app-go"]
