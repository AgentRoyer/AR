FROM rust:latest as builder
WORKDIR /app
COPY ./Cargo.toml ./
COPY ./src ./src
RUN cargo build --release
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/target/release/app-rust /app/
EXPOSE 8000
ENV RUST_LOG=info
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 CMD curl -f http://localhost:8000/health || exit 1
CMD ["./app-rust"]
