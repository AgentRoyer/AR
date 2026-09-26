# 005 Add CFML Chatbot & Change Colors

**Ajouter COLDFINA (CFML) et ajouter les couleurs à tous les chatbots.**

Stack colors (Métaux et minéraux):
- COLDFINA (CFML): BLEU
- PYTHONA (Python): VERT (émeraude)
- RUSTINA (Rust): ROUGE (cuivre/fer)
- GONA (Go): ORANGE (or/bronze)

---

## Steps

1. echo "Starting: Add CFML chatbot COLDFINA and colors to all bots..."

2. mkdir -p app-cfml/Projects/chatbot

3. echo "=== CFML: Create COLDFINA chatbot ==="

4. cat > app-cfml/Projects/chatbot/index.cfm << 'EOF'
<cfset chatbotName = "COLDFINA">
<cfset chatbotVersion = "1.0.0">
<cfset botColor = "blue">

<cfcontent type="application/json">

{
  "message": "Welcome to COLDFINA Chatbot",
  "name": "#chatbotName#",
  "version": "#chatbotVersion#",
  "color": "#botColor#",
  "description": "Un espace calme pour réfléchir, écrire et avancer avec un assistant propulsé par Groq sous CFML"
}
EOF

5. cat > app-cfml/Projects/chatbot/chatbot.cfm << 'EOF'
<cfset chatbotName = "COLDFINA">
<cfset chatbotVersion = "1.0.0">
<cfset botColor = "blue">
<cfset systemPrompt = "You are COLDFINA, a helpful AI chatbot powered by Groq under CFML. You know your name and identity. When asked who you are or what your name is, answer clearly and confidently.">

<cfif structKeyExists(URL, "method") AND URL.method EQ "identity">
    <cfcontent type="application/json">
    {
      "name": "#chatbotName#",
      "system_prompt": "#systemPrompt#",
      "version": "#chatbotVersion#",
      "color": "#botColor#",
      "knows_identity": true
    }
    <cfabort>
</cfif>

<cfif structKeyExists(URL, "method") AND URL.method EQ "health">
    <cfcontent type="application/json">
    {
      "status": "healthy",
      "bot": "#chatbotName#",
      "color": "#botColor#",
      "identity_aware": true
    }
    <cfabort>
</cfif>

<cfif structKeyExists(form, "message") OR structKeyExists(url, "message")>
    <cfset userMessage = structKeyExists(form, "message") ? form.message : url.message>
    
    <cffunction name="generateResponse" returntype="string">
        <cfargument name="userMessage" type="string" required="true">
        <cfset var messageLower = lcase(arguments.userMessage)>
        
        <cfif findNoCase("qui", messageLower) OR findNoCase("name", messageLower) OR findNoCase("appel", messageLower) OR findNoCase("suis-je", messageLower) OR findNoCase("who are you", messageLower) OR findNoCase("what is your name", messageLower)>
            <cfreturn "Je suis #chatbotName#, un assistant IA alimenté par Groq sous CFML. C'est mon identité et ma raison d'être!">
        </cfif>
        
        <cfif findNoCase("comment", messageLower) OR findNoCase("tes-tu", messageLower) OR findNoCase("are you", messageLower) OR findNoCase("ton nom", messageLower)>
            <cfreturn "Mon nom est #chatbotName#. Je suis un chatbot intelligent propulsé par Groq sous CFML.">
        </cfif>
        
        <cfreturn "#chatbotName# responds: Hello! You said '#arguments.userMessage#'. Comment puis-je vous aider?">
    </cffunction>
    
    <cfset response = generateResponse(userMessage)>
    
    <cfcontent type="application/json">
    {
      "bot": "#chatbotName#",
      "user_input": "#userMessage#",
      "response": "#response#",
      "identity": "#chatbotName#",
      "color": "#botColor#"
    }
    <cfabort>
</cfif>

<cfcontent type="application/json">
{
  "bot": "#chatbotName#",
  "message": "Use POST or GET to send messages to chatbot",
  "color": "#botColor#",
  "system_prompt": "#systemPrompt#"
}
EOF

6. cat > app-cfml/Projects/chatbot/health.cfm << 'EOF'
<cfcontent type="application/json">
{
  "status": "healthy",
  "bot": "COLDFINA",
  "color": "blue",
  "identity_aware": true
}
EOF

7. echo "=== PYTHON: Add color to PYTHONA ==="

8. cat > app-python/Projects/chatbot/app.py << 'EOF'
from flask import Flask, jsonify, request

app = Flask(__name__)

# Chatbot PYTHONA
CHATBOT_NAME = "PYTHONA"
CHATBOT_VERSION = "1.0.0"
BOT_COLOR = "green"  # Émeraude
SYSTEM_PROMPT = "You are PYTHONA, a helpful AI chatbot powered by Groq under Python. You know your name and identity. When asked who you are or what your name is, answer clearly and confidently."

@app.route('/')
def index():
    return jsonify({
        "message": "Welcome to PYTHONA Chatbot",
        "name": CHATBOT_NAME,
        "version": CHATBOT_VERSION,
        "color": BOT_COLOR,
        "description": "Un espace calme pour réfléchir, écrire et avancer avec un assistant propulsé par Groq sous Python"
    })

@app.route('/chatbot', methods=['GET', 'POST'])
def chatbot():
    if request.method == 'POST':
        data = request.get_json()
        user_message = data.get('message', '')
        
        # Simulate AI response with identity
        response = generate_response(user_message)
        
        return jsonify({
            "bot": CHATBOT_NAME,
            "user_input": user_message,
            "response": response,
            "identity": CHATBOT_NAME,
            "color": BOT_COLOR
        })
    
    return jsonify({
        "bot": CHATBOT_NAME,
        "message": "Use POST to send messages to chatbot",
        "color": BOT_COLOR,
        "system_prompt": SYSTEM_PROMPT
    })

def generate_response(user_message):
    """Generate response based on user message, respecting identity"""
    message_lower = user_message.lower()
    
    # Identity questions
    if any(word in message_lower for word in ['qui', 'name', 'appel', 'suis-je', 'who are you', 'what is your name']):
        return f"Je suis {CHATBOT_NAME}, un assistant IA alimenté par Groq sous Python. C'est mon identité et ma raison d'être!"
    
    if any(word in message_lower for word in ['comment', 'tes-tu', 'are you', 'ton nom']):
        return f"Mon nom est {CHATBOT_NAME}. Je suis un chatbot intelligent propulsé par Groq sous Python."
    
    # Default response
    return f"{CHATBOT_NAME} responds: Hello! You said '{user_message}'. Comment puis-je vous aider?"

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy",
        "bot": CHATBOT_NAME,
        "color": BOT_COLOR,
        "identity_aware": True
    }), 200

@app.route('/identity', methods=['GET'])
def identity():
    return jsonify({
        "name": CHATBOT_NAME,
        "system_prompt": SYSTEM_PROMPT,
        "version": CHATBOT_VERSION,
        "color": BOT_COLOR,
        "knows_identity": True
    }), 200

if __name__ == '__main__':
    print(f"🐍 {CHATBOT_NAME} starting on port 5000...")
    print(f"   Color: {BOT_COLOR} (Émeraude)")
    print(f"   System Prompt: {SYSTEM_PROMPT}")
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF

9. echo "=== RUST: Add color to RUSTINA ==="

10. cat > app-rust/Projects/chatbot/src/main.rs << 'EOF'
use axum::{
    extract::Json,
    http::StatusCode,
    routing::{get, post},
    Router,
};
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;

#[derive(Serialize)]
struct ChatResponse {
    bot: String,
    response: String,
    identity: String,
    color: String,
}

#[derive(Serialize)]
struct InfoResponse {
    message: String,
    name: String,
    version: String,
    color: String,
    description: String,
}

#[derive(Deserialize)]
struct ChatRequest {
    message: String,
}

const CHATBOT_NAME: &str = "RUSTINA";
const CHATBOT_VERSION: &str = "1.0.0";
const BOT_COLOR: &str = "red"; // Cuivre/fer
const SYSTEM_PROMPT: &str = "You are RUSTINA, a helpful AI chatbot powered by Groq under Rust. You know your name and identity. When asked who you are or what your name is, answer clearly and confidently.";

async fn index() -> Json<InfoResponse> {
    Json(InfoResponse {
        message: "Welcome to RUSTINA Chatbot".to_string(),
        name: CHATBOT_NAME.to_string(),
        version: CHATBOT_VERSION.to_string(),
        color: BOT_COLOR.to_string(),
        description: "Un espace calme pour réfléchir, écrire et avancer avec un assistant propulsé par Groq sous Rust".to_string(),
    })
}

fn generate_response(user_message: &str) -> String {
    let message_lower = user_message.to_lowercase();
    
    if message_lower.contains("qui") 
        || message_lower.contains("name") 
        || message_lower.contains("appel")
        || message_lower.contains("suis-je")
        || message_lower.contains("who are you")
        || message_lower.contains("what is your name") {
        return format!("Je suis {}, un assistant IA alimenté par Groq sous Rust. C'est mon identité et ma raison d'être!", CHATBOT_NAME);
    }
    
    if message_lower.contains("comment")
        || message_lower.contains("tes-tu")
        || message_lower.contains("are you")
        || message_lower.contains("ton nom") {
        return format!("Mon nom est {}. Je suis un chatbot intelligent propulsé par Groq sous Rust.", CHATBOT_NAME);
    }
    
    format!("{} responds: Hello! You said '{}'. Comment puis-je vous aider?", CHATBOT_NAME, user_message)
}

async fn chatbot(Json(payload): Json<ChatRequest>) -> Json<ChatResponse> {
    let response = generate_response(&payload.message);
    Json(ChatResponse {
        bot: CHATBOT_NAME.to_string(),
        response,
        identity: CHATBOT_NAME.to_string(),
        color: BOT_COLOR.to_string(),
    })
}

async fn health() -> (StatusCode, Json<serde_json::Value>) {
    (
        StatusCode::OK,
        Json(serde_json::json!({
            "status": "healthy",
            "bot": CHATBOT_NAME,
            "color": BOT_COLOR,
            "identity_aware": true
        })),
    )
}

async fn identity() -> Json<serde_json::Value> {
    Json(serde_json::json!({
        "name": CHATBOT_NAME,
        "system_prompt": SYSTEM_PROMPT,
        "version": CHATBOT_VERSION,
        "color": BOT_COLOR,
        "knows_identity": true
    }))
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(index))
        .route("/chatbot", post(chatbot))
        .route("/health", get(health))
        .route("/identity", get(identity));

    let addr = SocketAddr::from(([0, 0, 0, 0], 8000));
    println!("🔴 {} starting on {}...", CHATBOT_NAME, addr);
    println!("   Color: {} (Cuivre/fer)", BOT_COLOR);
    println!("   System Prompt: {}", SYSTEM_PROMPT);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}
EOF

11. echo "=== GO: Add color to GONA ==="

12. cat > app-go/Projects/chatbot/main.go << 'EOF'
package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"

	"github.com/gorilla/mux"
)

const (
	CHATBOT_NAME    = "GONA"
	CHATBOT_VERSION = "1.0.0"
	BOT_COLOR       = "orange" // Or/bronze
	SYSTEM_PROMPT   = "You are GONA, a helpful AI chatbot powered by Groq under Go. You know your name and identity. When asked who you are or what your name is, answer clearly and confidently."
)

type Response struct {
	Message        string `json:"message,omitempty"`
	Name           string `json:"name,omitempty"`
	Version        string `json:"version,omitempty"`
	Status         string `json:"status,omitempty"`
	Bot            string `json:"bot,omitempty"`
	Color          string `json:"color,omitempty"`
	Description    string `json:"description,omitempty"`
	SystemPrompt   string `json:"system_prompt,omitempty"`
	IdentityAware  bool   `json:"identity_aware,omitempty"`
	KnowsIdentity  bool   `json:"knows_identity,omitempty"`
}

type ChatRequest struct {
	Message string `json:"message"`
}

type ChatResponse struct {
	Bot       string `json:"bot"`
	UserInput string `json:"user_input"`
	Response  string `json:"response"`
	Identity  string `json:"identity"`
	Color     string `json:"color"`
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Message:     "Welcome to GONA Chatbot",
		Name:        CHATBOT_NAME,
		Version:     CHATBOT_VERSION,
		Color:       BOT_COLOR,
		Description: "Un espace calme pour réfléchir, écrire et avancer avec un assistant propulsé par Groq sous Go",
	}
	json.NewEncoder(w).Encode(resp)
}

func generateResponse(userMessage string) string {
	messageLower := strings.ToLower(userMessage)
	
	if strings.Contains(messageLower, "qui") || strings.Contains(messageLower, "appel") || strings.Contains(messageLower, "name") || strings.Contains(messageLower, "who are you") || strings.Contains(messageLower, "what is your name") {
		return fmt.Sprintf("Je suis %s, un assistant IA alimenté par Groq sous Go. C'est mon identité et ma raison d'être!", CHATBOT_NAME)
	}
	
	if strings.Contains(messageLower, "comment") || strings.Contains(messageLower, "tes-tu") || strings.Contains(messageLower, "are you") || strings.Contains(messageLower, "ton nom") {
		return fmt.Sprintf("Mon nom est %s. Je suis un chatbot intelligent propulsé par Groq sous Go.", CHATBOT_NAME)
	}
	
	return fmt.Sprintf("%s responds: Hello! You said '%s'. Comment puis-je vous aider?", CHATBOT_NAME, userMessage)
}

func chatbotHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if r.Method == "POST" {
		body, _ := io.ReadAll(r.Body)
		var chatReq ChatRequest
		json.Unmarshal(body, &chatReq)

		response := ChatResponse{
			Bot:       CHATBOT_NAME,
			UserInput: chatReq.Message,
			Response:  generateResponse(chatReq.Message),
			Identity:  CHATBOT_NAME,
			Color:     BOT_COLOR,
		}
		json.NewEncoder(w).Encode(response)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"bot":             CHATBOT_NAME,
		"message":         "Use POST to send messages to chatbot",
		"color":           BOT_COLOR,
		"system_prompt":   SYSTEM_PROMPT,
	})
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Response{
		Status:        "healthy",
		Bot:           CHATBOT_NAME,
		Color:         BOT_COLOR,
		IdentityAware: true,
	})
}

func identityHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Response{
		Name:          CHATBOT_NAME,
		SystemPrompt:  SYSTEM_PROMPT,
		Version:       CHATBOT_VERSION,
		Color:         BOT_COLOR,
		KnowsIdentity: true,
	})
}

func main() {
	router := mux.NewRouter()

	router.HandleFunc("/", indexHandler).Methods("GET")
	router.HandleFunc("/chatbot", chatbotHandler).Methods("GET", "POST")
	router.HandleFunc("/health", healthHandler).Methods("GET")
	router.HandleFunc("/identity", identityHandler).Methods("GET")

	fmt.Printf("🟠 %s starting on port 8080...\n", CHATBOT_NAME)
	fmt.Printf("   Color: %s (Or/bronze)\n", BOT_COLOR)
	fmt.Printf("   System Prompt: %s\n", SYSTEM_PROMPT)
	log.Fatal(http.ListenAndServe(":8080", router))
}
EOF

13. echo "Rebuilding and restarting all four chatbots..."

14. docker-compose down

15. docker-compose build app-cfml app-rust app-python app-go

16. docker-compose up -d app-cfml app-rust app-python app-go

17. sleep 15

18. echo "=== Testing all four chatbots with their colors ==="

19. echo "🔵 COLDFINA (CFML, port 8001, BLEU):"

20. curl -k https://literate-bassoon-xrr7x4qwqqv4hq4-8001.app.github.dev/ | jq .

21. curl -k -X POST "https://literate-bassoon-xrr7x4qwqqv4hq4-8001.app.github.dev/chatbot.cfm" -H "Content-Type: application/json" -d '{"message":"Qui es-tu?"}' || curl -k "https://literate-bassoon-xrr7x4qwqqv4hq4-8001.app.github.dev/chatbot.cfm?message=Qui%20es-tu?" | jq .

22. echo "🟢 PYTHONA (Python, port 8004, VERT):"

23. curl -k https://literate-bassoon-xrr7x4qwqqv4hq4-8004.app.github.dev/ | jq .

24. curl -k -X POST https://literate-bassoon-xrr7x4qwqqv4hq4-8004.app.github.dev/chatbot -H "Content-Type: application/json" -d '{"message":"Qui es-tu?"}' | jq .

25. echo "🔴 RUSTINA (Rust, port 8002, ROUGE):"

26. curl -k https://literate-bassoon-xrr7x4qwqqv4hq4-8002.app.github.dev/ | jq .

27. curl -k -X POST https://literate-bassoon-xrr7x4qwqqv4hq4-8002.app.github.dev/chatbot -H "Content-Type: application/json" -d '{"message":"Qui es-tu?"}' | jq .

28. echo "🟠 GONA (Go, port 8003, ORANGE):"

29. curl -k https://literate-bassoon-xrr7x4qwqqv4hq4-8003.app.github.dev/ | jq .

30. curl -k -X POST https://literate-bassoon-xrr7x4qwqqv4hq4-8003.app.github.dev/chatbot -H "Content-Type: application/json" -d '{"message":"Qui es-tu?"}' | jq .

31. echo "=== Testing /identity endpoints with colors ==="

32. echo "🔵 COLDFINA identity:" && curl -k "https://literate-bassoon-xrr7x4qwqqv4hq4-8001.app.github.dev/chatbot.cfm?method=identity" | jq .

33. echo "🟢 PYTHONA identity:" && curl -k https://literate-bassoon-xrr7x4qwqqv4hq4-8004.app.github.dev/identity | jq .

34. echo "🔴 RUSTINA identity:" && curl -k https://literate-bassoon-xrr7x4qwqqv4hq4-8002.app.github.dev/identity | jq .

35. echo "🟠 GONA identity:" && curl -k https://literate-bassoon-xrr7x4qwqqv4hq4-8003.app.github.dev/identity | jq .

36. docker-compose ps

37. git add app-cfml/ app-python/ app-rust/ app-go/ && git commit -m "005: Add CFML chatbot COLDFINA and colors to all four stacks"

38. git push

## Success Criteria

- ✓ COLDFINA (CFML) created on port 8001, color: BLEU
- ✓ PYTHONA (Python) updated, color: VERT
- ✓ RUSTINA (Rust) updated, color: ROUGE
- ✓ GONA (Go) updated, color: ORANGE
- ✓ All chatbots respond with color field in JSON
- ✓ All chatbots respond to identity questions
- ✓ All have /identity endpoint with color
- ✓ CFML chatbot uses index.cfm and chatbot.cfm
- ✓ All four services running and healthy
- ✓ Git committed and pushed

## Color Scheme (Métaux et minéraux)

```
🔵 COLDFINA (CFML):  BLEU       (Eau)
🟢 PYTHONA  (Python): VERT       (Émeraude)
🔴 RUSTINA  (Rust):   ROUGE      (Cuivre/Fer)
🟠 GONA     (Go):     ORANGE     (Or/Bronze)
```

## API Endpoints by Stack

### COLDFINA (CFML) - Port 8001
```
GET  /                           → Info + color
GET  /chatbot.cfm?message=...    → Chat response
GET  /chatbot.cfm?method=identity → Identity info
GET  /health.cfm                  → Health + color
```

### PYTHONA (Python) - Port 8004
```
GET  /                           → Info + color
POST /chatbot                    → Chat response + color
GET  /identity                   → Identity + color
GET  /health                     → Health + color
```

### RUSTINA (Rust) - Port 8002
```
GET  /                           → Info + color
POST /chatbot                    → Chat response + color
GET  /identity                   → Identity + color
GET  /health                     → Health + color
```

### GONA (Go) - Port 8003
```
GET  /                           → Info + color
POST /chatbot                    → Chat response + color
GET  /identity                   → Identity + color
GET  /health                     → Health + color
```

## Test Queries (All with Colors)

```bash
# COLDFINA (BLEU)
curl "https://...8001.../chatbot.cfm?message=Qui%20es-tu?"

# PYTHONA (VERT)
curl -X POST https://...8004.../chatbot \
  -H "Content-Type: application/json" \
  -d '{"message":"Qui es-tu?"}'

# RUSTINA (ROUGE)
curl -X POST https://...8002.../chatbot \
  -H "Content-Type: application/json" \
  -d '{"message":"Qui es-tu?"}'

# GONA (ORANGE)
curl -X POST https://...8003.../chatbot \
  -H "Content-Type: application/json" \
  -d '{"message":"Qui es-tu?"}'
```

## Response Example (with color)

```json
{
  "bot": "PYTHONA",
  "user_input": "Qui es-tu?",
  "response": "Je suis PYTHONA, un assistant IA alimenté par Groq sous Python. C'est mon identité et ma raison d'être!",
  "identity": "PYTHONA",
  "color": "green"
}
```

## Stack Summary

| Bot       | Stack | Port | Color  | Status    |
|-----------|-------|------|--------|-----------|
| COLDFINA  | CFML  | 8001 | 🔵 Bleu  | ✅ New   |
| PYTHONA   | Python| 8004 | 🟢 Vert  | ✅ Updated |
| RUSTINA   | Rust  | 8002 | 🔴 Rouge | ✅ Updated |
| GONA      | Go    | 8003 | 🟠 Orange| ✅ Updated |

## Prochaines Étapes

1. ✅ Quatre chatbots avec identités
2. ✅ Quatre couleurs distinctes (métaux/minéraux)
3. ⏳ Intégrer Groq API réelle pour réponses intelligentes
4. ⏳ Ajouter mémoire de conversation
5. ⏳ Interface web pour visualiser les couleurs
6. ⏳ Déployer en production sur Railway

---

**🎉 Four Colored Agents: COLDFINA🔵 + PYTHONA🟢 + RUSTINA🔴 + GONA🟠 = FULL STACK IDENTITY**
