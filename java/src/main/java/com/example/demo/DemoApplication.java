package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
        String port = System.getenv("SERVER_PORT") != null ? System.getenv("SERVER_PORT") : System.getenv("PORT") != null ? System.getenv("PORT") : "8015";
        System.out.println("Starting server at http://0.0.0.0:" + port);
    }
}

