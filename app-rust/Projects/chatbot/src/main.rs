use std::io::{Read, Write};

use serde::{Deserialize, Serialize};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn timestamp_format_matches_dd_mm_yyyy_hh_mm() {
        let dt = chrono::NaiveDate::from_ymd_opt(2024, 5, 7)
            .unwrap()
            .and_hms_opt(9, 8, 0)
            .unwrap();

        assert_eq!(format_datetime(dt), "07/05/2024 09:08");
    }

    #[test]
    fn page_contains_hello_world_and_timestamp() {
        let html = render_index("07/05/2024 09:08");
        assert!(html.contains("RUSTINA"));
        assert!(html.contains("07/05/2024 09:08"));
        assert!(html.contains("/api/chat"));
    }
}

#[derive(Deserialize)]
struct ChatRequest {
    messages: Vec<ChatMessage>,
}

#[derive(Clone, Deserialize, Serialize)]
struct ChatMessage {
    role: String,
    content: String,
}

#[derive(Deserialize)]
struct GroqResponse {
    choices: Vec<GroqChoice>,
}

#[derive(Deserialize)]
struct GroqChoice {
    message: ChatMessage,
}

#[derive(Serialize)]
struct ChatResponse {
    message: ChatMessage,
}

// API commune aux chatbots RUSTINA / PYTHONA / GONA : POST /chatbot {"message": "..."}
#[derive(Deserialize)]
struct BotRequest {
    message: String,
}

#[derive(Serialize)]
struct BotResponse {
    bot: &'static str,
    user_input: String,
    response: String,
    identity: &'static str,
}

const CHATBOT_NAME: &str = "RUSTINA";
const CHATBOT_VERSION: &str = "1.0.0";
const SYSTEM_PROMPT: &str = "You are RUSTINA, a helpful AI chatbot powered by Groq under Rust. You know your name and identity. When asked who you are or what your name is, answer clearly and confidently.";

fn format_datetime(dt: chrono::NaiveDateTime) -> String {
    dt.format("%d/%m/%Y %H:%M").to_string()
}

fn render_index(timestamp: &str) -> String {
    format!(
        r##"<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>RUSTINA — Assistant IA</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500&family=Manrope:wght@400;600;700;800&display=swap" rel="stylesheet" />
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
      tailwind.config = {{
        theme: {{
          extend: {{
            fontFamily: {{ sans: ['Manrope', 'sans-serif'], mono: ['DM Mono', 'monospace'] }}
          }}
        }}
      }}
    </script>
  </head>
    <body class="min-h-screen bg-[#0d1420] font-sans text-[#eef5ff] antialiased">
        <div class="pointer-events-none fixed inset-0 opacity-40" style="background-image: linear-gradient(rgba(168, 200, 240, .045) 1px, transparent 1px), linear-gradient(90deg, rgba(168, 200, 240, .045) 1px, transparent 1px); background-size: 48px 48px;"></div>
    <main class="relative mx-auto flex min-h-screen max-w-7xl flex-col px-5 py-5 md:px-10 md:py-8">
            <header class="flex items-center justify-between border-b border-[#c5dcff]/15 pb-5">
                <div class="flex items-center gap-3"><span class="grid h-9 w-9 place-items-center rounded-full bg-[#c5dcff] text-[#0d1420] font-black">R</span><span class="font-mono text-sm tracking-[.28em] text-[#c5dcff]">RUSTINA</span></div>
                <div class="flex items-center gap-3 font-mono text-[10px] uppercase tracking-[.16em] text-[#9aa9bc]"><span class="h-2 w-2 rounded-full bg-[#6fb3ff] shadow-[0_0_12px_#6fb3ff]"></span> Groq connecté</div>
      </header>
      <section class="grid flex-1 gap-8 py-10 lg:grid-cols-[.75fr_1.45fr] lg:gap-16 lg:py-16">
        <div class="flex flex-col justify-between">
          <div><p class="mb-5 font-mono text-xs uppercase tracking-[.24em] text-[#6fb3ff]">Conversation privée · {timestamp}</p><h1 class="max-w-lg text-5xl font-extrabold leading-[.98] tracking-[-.06em] text-[#eef5ff] md:text-7xl">Laissez les idées prendre forme.</h1><p class="mt-7 max-w-md text-base leading-7 text-[#a7b4c7]">Un espace calme pour réfléchir, écrire et avancer avec un assistant propulsé par Groq sous Rust.</p></div>
          <div class="mt-12 hidden border-t border-[#c5dcff]/15 pt-5 lg:block"><p class="font-mono text-[10px] uppercase tracking-[.18em] text-[#6f7d91]">Modèle actif</p><p class="mt-2 text-sm text-[#c5dcff]">GPT OSS 20B</p></div>
        </div>
                <div class="flex min-h-[580px] flex-col border border-[#c5dcff]/20 bg-[#131d2d]/90 shadow-2xl shadow-black/20">
                    <div class="flex items-center justify-between border-b border-[#c5dcff]/15 px-5 py-4"><span class="font-mono text-xs text-[#9aa9bc]">NOUVELLE CONVERSATION</span><button id="clear" class="text-xs text-[#9aa9bc] transition hover:text-[#c5dcff]">Effacer</button></div>
                    <div id="messages" class="flex flex-1 flex-col gap-6 overflow-y-auto p-5 md:p-8"><div class="max-w-xl"><p class="mb-2 font-mono text-[10px] uppercase tracking-[.16em] text-[#6fb3ff]">RUSTINA · maintenant</p><p class="text-lg leading-8 text-[#e3edf9]">Bonjour. Qu'est-ce qu'on construit aujourd'hui ?</p></div></div>
                    <form id="chat-form" class="border-t border-[#c5dcff]/15 p-4 md:p-5"><div class="flex items-end gap-3 border border-[#c5dcff]/20 bg-[#0d1420] p-3 focus-within:border-[#6fb3ff]/70"><textarea id="prompt" rows="2" placeholder="Écrivez votre message..." class="min-h-[52px] flex-1 resize-none bg-transparent px-2 py-1 text-sm leading-6 text-[#eef5ff] outline-none placeholder:text-[#64748b]"></textarea><button id="send" type="submit" aria-label="Envoyer" class="grid h-11 w-11 shrink-0 place-items-center rounded-full bg-[#c5dcff] text-[#0d1420] transition hover:bg-[#6fb3ff] disabled:cursor-not-allowed disabled:opacity-50"><span class="text-xl">↗</span></button></div><p id="status" class="mt-3 min-h-4 font-mono text-[10px] text-[#6f7d91]"></p></form>
        </div>
      </section>
    </main>
    <script>
      const form = document.querySelector('#chat-form'), input = document.querySelector('#prompt'), messages = document.querySelector('#messages'), status = document.querySelector('#status'), send = document.querySelector('#send');
      const history = [];
    function addMessage(role, content) {{ const item = document.createElement('div'); item.className = role === 'user' ? 'ml-auto max-w-xl text-right' : 'max-w-xl'; item.innerHTML = `<p class="mb-2 font-mono text-[10px] uppercase tracking-[.16em] ${{role === 'user' ? 'text-[#9aa9bc]' : 'text-[#6fb3ff]'}}">${{role === 'user' ? 'VOUS' : 'RUSTINA'}} · maintenant</p><p class="text-base leading-8 text-[#e3edf9] whitespace-pre-wrap">${{content.replace(/[&<>]/g, c => ({{'&':'&amp;','<':'&lt;','>':'&gt;'}}[c]))}}</p>`; messages.appendChild(item); messages.scrollTop = messages.scrollHeight; }}
      form.addEventListener('submit', async (event) => {{ event.preventDefault(); const content = input.value.trim(); if (!content) return; addMessage('user', content); history.push({{ role: 'user', content }}); input.value = ''; send.disabled = true; status.textContent = 'RUSTINA réfléchit...'; try {{ const response = await fetch('/api/chat', {{ method: 'POST', headers: {{ 'Content-Type': 'application/json' }}, body: JSON.stringify({{ messages: history }}) }}); const data = await response.json(); if (!response.ok) throw new Error(data.error || 'La réponse n’a pas pu être récupérée.'); addMessage('assistant', data.message.content); history.push(data.message); status.textContent = ''; }} catch (error) {{ addMessage('assistant', `Erreur : ${{error.message}}`); status.textContent = 'Vérifiez GROQ_API_KEY_CFC côté serveur.'; }} finally {{ send.disabled = false; input.focus(); }} }});
      document.querySelector('#clear').addEventListener('click', () => {{ history.length = 0; messages.innerHTML = ''; addMessage('assistant', 'Conversation réinitialisée. Que voulez-vous explorer ?'); }});
      input.addEventListener('keydown', event => {{ if (event.key === 'Enter' && !event.shiftKey) {{ event.preventDefault(); form.requestSubmit(); }} }});
    </script>
  </body>
</html>
"##
    )
}

fn chat_response(request: &ChatRequest) -> Result<String, String> {
    let message = groq_complete(&request.messages)?;
    Ok(serde_json::to_string(&ChatResponse { message }).unwrap())
}

fn bot_response(request: &BotRequest) -> Result<String, String> {
    let messages = [ChatMessage { role: "user".to_string(), content: request.message.clone() }];
    let reply = groq_complete(&messages)?;
    Ok(serde_json::to_string(&BotResponse {
        bot: CHATBOT_NAME,
        user_input: request.message.clone(),
        response: reply.content,
        identity: CHATBOT_NAME,
    })
    .unwrap())
}

fn groq_complete(messages: &[ChatMessage]) -> Result<ChatMessage, String> {
    // Identité : le prompt système précède toujours la conversation
    let mut messages_with_system = vec![ChatMessage { role: "system".to_string(), content: SYSTEM_PROMPT.to_string() }];
    messages_with_system.extend_from_slice(messages);
    // Clé fournie par le .env de la racine du codespace (docker-compose env_file)
    let api_key = std::env::var("GROQ_API_KEY_CFC")
        .ok()
        .filter(|key| !key.trim().is_empty())
        .ok_or_else(|| "GROQ_API_KEY_CFC est manquante sur le serveur.".to_string())?;
    let response = reqwest::blocking::Client::new()
        .post("https://api.groq.com/openai/v1/chat/completions")
        .bearer_auth(api_key)
        .json(&serde_json::json!({ "model": "openai/gpt-oss-20b", "messages": messages_with_system, "temperature": 0.7 }))
        .send()
        .map_err(|error| format!("Impossible de joindre Groq : {error}"))?;
    if !response.status().is_success() {
        return Err(format!("Groq a renvoyé le statut {}.", response.status()));
    }
    let data: GroqResponse = response
        .json()
        .map_err(|error| format!("Réponse Groq invalide : {error}"))?;
    data.choices
        .first()
        .map(|choice| choice.message.clone())
        .ok_or_else(|| "Groq n’a renvoyé aucun message.".to_string())
}

fn main() {
    // 8000 : port attendu par docker-compose (8002:8000), nginx et le healthcheck
    let port = std::env::var("PORT").unwrap_or_else(|_| "8000".to_string());
    let addr = format!("0.0.0.0:{port}");
    println!("Serving on http://{addr}");

    let listener = std::net::TcpListener::bind(addr).unwrap();

    for stream in listener.incoming() {
        let mut stream = stream.unwrap();
        let mut buffer = [0; 65536];
        let _ = stream.read(&mut buffer).unwrap();

        let request = String::from_utf8_lossy(&buffer[..]);
        let request_line = request.lines().next().unwrap_or("");
        let mut request_parts = request_line.split_whitespace();
        let method = request_parts.next().unwrap_or("");
        let path = request_parts.next().unwrap_or("/");
        let now = chrono::Local::now().naive_local();
        let timestamp = format_datetime(now);

        let (status, content_type, body) = if method != "POST" && matches!(path, "/" | "/index.html" | "/chatbot" | "/chatbot/") {
            (
                "200 OK",
                "text/html; charset=utf-8",
                render_index(&timestamp),
            )
        } else if path == "/identity" {
            (
                "200 OK",
                "application/json",
                serde_json::json!({
                    "name": CHATBOT_NAME,
                    "system_prompt": SYSTEM_PROMPT,
                    "version": CHATBOT_VERSION,
                    "knows_identity": true
                })
                .to_string(),
            )
        } else if path == "/health" {
            ("200 OK", "text/plain; charset=utf-8", "OK".to_string())
        } else if method == "POST" && path == "/chatbot" {
            let body = request
                .split("\r\n\r\n")
                .nth(1)
                .unwrap_or("")
                .trim_matches('\0')
                .trim();
            match serde_json::from_str::<BotRequest>(body) {
                Ok(request) => match bot_response(&request) {
                    Ok(response) => ("200 OK", "application/json", response),
                    Err(error) => (
                        "502 Bad Gateway",
                        "application/json",
                        serde_json::json!({ "bot": CHATBOT_NAME, "error": error }).to_string(),
                    ),
                },
                Err(error) => (
                    "400 Bad Request",
                    "application/json",
                    serde_json::json!({ "error": format!("JSON invalide : {error}") }).to_string(),
                ),
            }
        } else if method == "POST" && path == "/api/chat" {
            let body = request
                .split("\r\n\r\n")
                .nth(1)
                .unwrap_or("")
                .trim_matches('\0')
                .trim();
            match serde_json::from_str::<ChatRequest>(body) {
                Ok(request) => match chat_response(&request) {
                    Ok(response) => ("200 OK", "application/json", response),
                    Err(error) => (
                        "502 Bad Gateway",
                        "application/json",
                        serde_json::json!({ "error": error }).to_string(),
                    ),
                },
                Err(error) => (
                    "400 Bad Request",
                    "application/json",
                    serde_json::json!({ "error": format!("JSON invalide : {error}") }).to_string(),
                ),
            }
        } else {
            (
                "404 Not Found",
                "text/plain; charset=utf-8",
                "Not Found".to_string(),
            )
        };

        let response = format!(
            "HTTP/1.1 {status}\r\nContent-Type: {content_type}\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{}",
            body.len(),
            body
        );

        stream.write_all(response.as_bytes()).unwrap();
    }
}
