#include "crow_all.h"
#include <iostream>
#include <chrono>
#include <iomanip>
#include <sstream>
#include <cstdlib>
#include <random>

std::string current_timestamp_rfc3339() {
    using namespace std::chrono;
    auto now = system_clock::now();
    auto time_t_now = system_clock::to_time_t(now);
    auto tm = *std::gmtime(&time_t_now);

    std::ostringstream ss;
    ss << std::put_time(&tm, "%Y-%m-%dT%H:%M:%S") << "Z";
    return ss.str();
}

static std::string trace_id_from_request(const crow::request& req) {
    const auto header = req.get_header_value("X-Trace-Id");
    if (!header.empty()) return header;

    std::random_device rd;
    std::uniform_int_distribution<int> dist(0, 15);
    const char* hex = "0123456789abcdef";
    std::string out;
    out.reserve(32);
    for (int i = 0; i < 32; i++) out.push_back(hex[dist(rd)]);
    return out;
}

int main() {
    crow::SimpleApp app;
    int port = 8010;
    if (const char* port_env = std::getenv("PORT"); port_env && *port_env) {
        try {
            port = std::stoi(port_env);
        } catch (...) {
            std::cerr << "Invalid PORT env var: " << port_env << " (using 8010)" << std::endl;
            port = 8010;
        }
    }

    CROW_ROUTE(app, "/")([](const crow::request& req) {
        const auto trace_id = trace_id_from_request(req);
        const auto timestamp = current_timestamp_rfc3339();
        std::cout
            << "{\"code\":200,\"message\":\"OK\",\"method\":\"GET\",\"path\":\"/\",\"trace_id\":\""
            << trace_id
            << "\",\"timestamp\":\""
            << timestamp
            << "\"}"
            << std::endl;

        crow::json::wvalue x;
        x["status"] = "success";
        x["message"] = "Hello cpp";
        x["timestamp"] = timestamp;
        return crow::response(200, x);
    });

    std::cout << "Starting server at http://127.0.0.1:" << port << std::endl;
    app.port(port).multithreaded().run();
}

