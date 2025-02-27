package com.brianlukonsolo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class MicroserviceApplication {

    public static void main(String[] args) {
        SpringApplication.run(MicroserviceApplication.class, args);
    }

    @GetMapping("/health")
    public String health() {
        return "Microservice is healthy!";
    }

    @GetMapping("/hello")
    public String hello() {
        return "Hello from the secure microservice!";
    }
}
