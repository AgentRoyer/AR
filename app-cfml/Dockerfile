FROM lucee/lucee:7.0
RUN apt-get update && apt-get install -y curl git && rm -rf /var/lib/apt/lists/*
WORKDIR /var/www
COPY ./Projects ./
EXPOSE 8888
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD curl -f http://localhost:8888/ || exit 1
CMD ["catalina.sh", "run"]
