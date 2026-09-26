# ARsetup - AgentRoyer Complete Setup

**Complete infrastructure setup for AgentRoyer in one executable file.**

Execute this with: `python run_task.py ARsetup.md`

---

## Steps

1. mkdir -p app-cfml/src app-cfml/config app-rust/src app-go app-python .speckit .certs .github/workflows speckit_md/app-{cfml,rust,go,python}

2. cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  app-cfml:
    build: ./app-cfml
    container_name: app-cfml
    ports:
      - "8001:8080"
    environment:
      LUCEE_ADMIN_PASSWORD: ${LUCEE_ADMIN_PASSWORD:-password}
    volumes:
      - ./app-cfml/src:/var/www/html
    networks:
      - agentroyer-net
    restart: unless-stopped

  app-rust:
    build: ./app-rust
    container_name: app-rust
    ports:
      - "8002:8000"
    environment:
      GROQ_API_KEY: ${GROQ_API_KEY}
      CLAUDE_API_KEY: ${CLAUDE_API_KEY}
      RUST_LOG: info
    volumes:
      - ./app-rust/src:/app/src
    networks:
      - agentroyer-net
    restart: unless-stopped

  app-go:
    build: ./app-go
    container_name: app-go
    ports:
      - "8003:8080"
    environment:
      PORT: 8080
    volumes:
      - ./app-go:/app
    networks:
      - agentroyer-net
    restart: unless-stopped

  app-python:
    build: ./app-python
    container_name: app-python
    ports:
      - "8004:5000"
    environment:
      FLASK_APP: app.py
      FLASK_ENV: development
    volumes:
      - ./app-python:/app
    networks:
      - agentroyer-net
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    container_name: agentroyer-nginx
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./.certs:/etc/nginx/certs:ro
    depends_on:
      - app-cfml
      - app-rust
      - app-go
      - app-python
    networks:
      - agentroyer-net
    restart: unless-stopped

networks:
  agentroyer-net:
    driver: bridge
EOF

3. cat > nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    log_format main '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"';
    access_log /var/log/nginx/access.log main;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;

    upstream cfml_backend { server app-cfml:8080; }
    upstream rust_backend { server app-rust:8000; }
    upstream go_backend { server app-go:8080; }
    upstream python_backend { server app-python:5000; }

    server {
        listen 80;
        server_name _;
        location / { return 301 https://$host$request_uri; }
    }

    server {
        listen 443 ssl http2;
        server_name cfml.localhost localhost;
        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
        location / {
            proxy_pass http://cfml_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    server {
        listen 443 ssl http2;
        server_name rust.localhost;
        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        location / {
            proxy_pass http://rust_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    server {
        listen 443 ssl http2;
        server_name go.localhost;
        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        location / {
            proxy_pass http://go_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    server {
        listen 443 ssl http2;
        server_name python.localhost;
        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        location / {
            proxy_pass http://python_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    server {
        listen 443 ssl http2 default_server;
        server_name _;
        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        location / {
            return 200 '<html><head><title>AgentRoyer</title></head><body><h1>🕵️ AgentRoyer - Local</h1><ul><li><a href="https://cfml.localhost">CFML</a></li><li><a href="https://rust.localhost">Rust</a></li><li><a href="https://go.localhost">Go</a></li><li><a href="https://python.localhost">Python</a></li></ul></body></html>';
            add_header Content-Type text/html;
        }
    }
}
EOF

4. cat > .env.example << 'EOF'
CLAUDE_API_KEY=sk-proj-...
GROQ_API_KEY=gsk-...
LUCEE_ADMIN_PASSWORD=change-me
DB_PASSWORD_CFML=change-me
DB_PASSWORD_RUST=change-me
EOF

5. cat > .gitignore << 'EOF'
.env
.env.local
.certs/
*.pem
*.key
.docker/
__pycache__/
*.py[cod]
target/
node_modules/
*.log
.DS_Store
Thumbs.db
EOF

6. cat > app-cfml/Dockerfile << 'EOF'
FROM lucee/lucee:7-latest
RUN apt-get update && apt-get install -y curl git && rm -rf /var/lib/apt/lists/*
WORKDIR /var/www/html
COPY ./app-cfml/src ./
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD curl -f http://localhost:8080/ || exit 1
CMD ["catalina.sh", "run"]
EOF

7. cat > app-rust/Dockerfile << 'EOF'
FROM rust:latest as builder
WORKDIR /app
COPY ./app-rust/Cargo.toml ./
COPY ./app-rust/src ./src
RUN cargo build --release
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/target/release/app-rust /app/
EXPOSE 8000
ENV RUST_LOG=info
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 CMD curl -f http://localhost:8000/health || exit 1
CMD ["./app-rust"]
EOF

8. cat > app-go/Dockerfile << 'EOF'
FROM golang:1.21-alpine as builder
WORKDIR /app
COPY ./app-go ./
RUN go build -o app-go .
FROM alpine:latest
RUN apk add --no-cache ca-certificates curl
WORKDIR /app
COPY --from=builder /app/app-go /app/
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD curl -f http://localhost:8080/health || exit 1
CMD ["./app-go"]
EOF

9. cat > app-python/Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY ./app-python/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY ./app-python ./
EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1
ENV FLASK_APP=app.py
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]
EOF

10. cat > app-cfml/src/index.cfm << 'EOF'
<html>
  <head><title>AgentRoyer - CFML</title></head>
  <body style="font-family: sans-serif; padding: 20px;">
    <h1>🕵️ CFML App - Lucee 7</h1>
    <p>Welcome to AgentRoyer CFML Service</p>
    <p>Timestamp: <cfoutput>#now()#</cfoutput></p>
  </body>
</html>
EOF

11. cat > app-rust/Cargo.toml << 'EOF'
[package]
name = "app-rust"
version = "0.1.0"
edition = "2021"

[dependencies]
axum = "0.6"
tokio = { version = "1", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
EOF

12. cat > app-rust/src/main.rs << 'EOF'
use axum::{response::IntoResponse, routing::get, Router};
use std::net::SocketAddr;

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(|| async { "🦀 Rust App - AgentRoyer" }))
        .route("/health", get(|| async { "OK" }));
    
    let addr = SocketAddr::from(([0, 0, 0, 0], 8000));
    println!("Server listening on {}", addr);
    
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}
EOF

13. cat > app-go/go.mod << 'EOF'
module agentroyer/app-go

go 1.21
EOF

14. cat > app-go/main.go << 'EOF'
package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "text/html")
        fmt.Fprintf(w, "<h1>🔵 Go App - AgentRoyer</h1>")
    })
    
    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
    })
    
    fmt.Println("Go server listening on :8080")
    http.ListenAndServe(":8080", nil)
}
EOF

15. cat > app-python/requirements.txt << 'EOF'
Flask==2.3.3
Werkzeug==2.3.7
EOF

16. cat > app-python/app.py << 'EOF'
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return '<h1>🐍 Python App - AgentRoyer</h1>'

@app.route('/health')
def health():
    return 'OK', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

17. cat > .env << 'EOF'
CLAUDE_API_KEY=sk-proj-your-key-here
GROQ_API_KEY=gsk-your-key-here
LUCEE_ADMIN_PASSWORD=secure-password
DB_PASSWORD_CFML=db-password
DB_PASSWORD_RUST=db-password
EOF

18. cp .env.example .env

19. cat > speckit_md/app-cfml/001-setup.md << 'EOF'
# 001 Setup CFML - Base Structure

1. echo "CFML setup initialized"
2. docker-compose ps
EOF

20. cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to Railway

on:
  push:
    branches: [main, master]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Railway
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
        run: |
          npm install -g @railway/cli
          railway login --token $RAILWAY_TOKEN
          railway up
      - name: Health checks
        run: sleep 30 && curl -f -k https://cfml.agenticdino.com/ || true
EOF

21. cat > .devcontainer.json << 'EOF'
{
  "name": "AgentRoyer",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-24.04",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/git:latest": {},
    "ghcr.io/devcontainers/features/python:3.11": {},
    "ghcr.io/devcontainers/features/rust:latest": {},
    "ghcr.io/devcontainers/features/go:1.21": {}
  },
  "customizations": {
    "vscode": {
      "extensions": ["ms-docker.docker", "rust-lang.rust-analyzer", "golang.Go", "ms-python.python"]
    }
  },
  "forwardPorts": [443, 8001, 8002, 8003, 8004],
  "remoteUser": "root"
}
EOF

22. chmod +x app-cfml/Dockerfile app-rust/Dockerfile app-go/Dockerfile app-python/Dockerfile

23. echo "Installing mkcert for SSL certificates..."

24. apt-get update && apt-get install -y mkcert

25. mkcert -install

26. mkcert -cert-file .certs/cert.pem -key-file .certs/key.pem localhost "*.localhost"

27. chmod 644 .certs/cert.pem && chmod 600 .certs/key.pem

28. echo "Building Docker images..."

29. docker-compose build

30. echo "Starting services..."

31. docker-compose up -d

32. sleep 15

33. echo "Testing CFML..."

34. curl -k https://cfml.localhost/ || curl http://localhost:8001/

35. echo "Testing Rust..."

36. curl -k https://rust.localhost/ || curl http://localhost:8002/

37. echo "Testing Go..."

38. curl -k https://go.localhost/ || curl http://localhost:8003/

39. echo "Testing Python..."

40. curl -k https://python.localhost/ || curl http://localhost:8004/

41. echo "Checking container status..."

42. docker-compose ps

43. echo "Displaying logs..."

44. docker-compose logs --tail=20

45. git add . && git commit -m "AgentRoyer: Complete setup - all services running"

46. git push

## Success Criteria

- ✓ Tous les dossiers créés
- ✓ Tous les fichiers générés
- ✓ SSL certificates créés
- ✓ Docker images buildées
- ✓ Tous les services lancés
- ✓ URLs répondent
- ✓ Git committed

## Vérification

```bash
docker-compose ps
# Doit montrer 5 containers: nginx, app-cfml, app-rust, app-go, app-python

curl -k https://cfml.localhost/
curl -k https://rust.localhost/
curl -k https://go.localhost/
curl -k https://python.localhost/
```

## URLs Disponibles

- https://cfml.localhost (CFML - Lucee 7)
- https://rust.localhost (Rust)
- https://go.localhost (Go)
- https://python.localhost (Python)
- https://localhost (Landing page)

## Notes Importantes

⚠️ **Secrets**: Remplir les vraies clés dans .env
- CLAUDE_API_KEY
- GROQ_API_KEY

⚠️ **Git**: Ne JAMAIS commiter .env (dans .gitignore)

✅ **Certificats SSL**: Auto-générés localement (self-signed OK)

✅ **State**: Voir .speckit/state.json pour les résultats

## Prochaines Étapes

1. Éditer .env avec tes vraies clés API
2. Tester les services en prod quand Railway sera linké
3. Migrer cfdino.com dans app-cfml/src
4. Intégrer Groq API dans Rust
5. Créer les tasks suivantes dans speckit_md/

---

**🎉 AgentRoyer setup complet!**
