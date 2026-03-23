use actix_web::{get, App, HttpRequest, HttpServer, HttpResponse, Responder};
use serde::Serialize;
use log::{info};
use chrono::Utc;
use std::env;
use uuid::Uuid;

#[derive(Serialize)]
struct ApiResponse {
    status: String,
    message: String,
    timestamp: String,
}

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

    let response = ApiResponse {
        status: "success".to_string(),
        message: "Hello rust".to_string(),
        timestamp: Utc::now().to_rfc3339(),
    };

    HttpResponse::Ok().json(response)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {

    env_logger::init();

    let port: u16 = env::var("PORT")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(8080);

    info!("Starting server at http://127.0.0.1:{}", port);

    HttpServer::new(|| {
        App::new()
            .service(hello)
    })
    .bind(("127.0.0.1", port))?
    .run()
    .await
}