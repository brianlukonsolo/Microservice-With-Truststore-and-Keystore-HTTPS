package com.brianlukonsolo.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class WiremockTestController {

    @Autowired
    private RestTemplate restTemplate;

    @GetMapping("/test-wiremock")
    public ResponseEntity<String> testWiremock() {
        String wiremockUrl = "https://wiremock:9091/test-endpoint";
        ResponseEntity<String> response = restTemplate.getForEntity(wiremockUrl, String.class);
        return ResponseEntity.ok("WireMock response: " + response.getBody());
    }
}
