use actix_web::{get, App, HttpRequest, HttpServer, HttpResponse, Responder};
use log::{info};
use chrono::Utc;
use std::env;
use uuid::Uuid;



#[get("/")]
async fn hello(req: HttpRequest) -> impl Responder {

    let trace_id = req
        .headers()
        .get("X-Trace-Id")
        .and_then(|v| v.to_str().ok())
        .map(|s| s.to_string())
        .unwrap_or_else(|| Uuid::new_v4().to_string());

    info!(
        "{}",
        serde_json::json!({
            "code": 200,
            "message": "OK",
            "method": req.method().as_str(),
            "path": req.path(),
            "trace_id": trace_id,
            "timestamp": Utc::now().to_rfc3339(),
        })
    );

    let response = serde_json::json!({
        "timestamp": Utc::now().to_rfc3339(),
        "level": "info",
        "service": "rust-api",
        "message": format!("{} {} success", req.method(), req.path()),
        "request": {
            "method": req.method().as_str(),
            "url": req.path(),
            "headers": {
                "user-agent": req.headers().get("User-Agent").and_then(|h| h.to_str().ok()).unwrap_or("")
            },
            "ip": req.peer_addr().map(|a| a.ip().to_string()).unwrap_or_else(|| "127.0.0.1".to_string())
        },
        "response": {
            "status_code": 200,
            "response_time_ms": 12
        },
        "meta": {
            "request_id": trace_id,
            "user_id": 42
        }
    });

    HttpResponse::Ok().json(response)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {

    env_logger::init();

    let port: u16 = env::var("PORT")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(7070);

    info!("Starting server at http://0.0.0.0:{}", port);

    HttpServer::new(|| {
        App::new()
            .service(hello)
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}

pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

// This is a really bad adding function, its purpose is to fail in this
// example.
#[allow(dead_code)]
fn bad_add(a: i32, b: i32) -> i32 {
    a - b
}

#[cfg(test)]
mod tests {
    // Note this useful idiom: importing names from outer (for mod tests) scope.
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(1, 2), 3);
    }

    // #[test]
    // fn test_bad_add() {
    //     // This assert would fire and test will fail.
    //     // Please note, that private functions can be tested too!
    //     assert_eq!(bad_add(1, 2), 3);
    // }
}