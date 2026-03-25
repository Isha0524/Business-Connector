package com.agriconnect.backend.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.net.http.*;
import java.util.*;

@RestController
@RequestMapping("/api/market-prices")
public class MarketPriceController {

        @Value("${datagov.api.key:DEMO_KEY}")
        private String apiKey;

        // ✅ नवीन Maharashtra Resource ID
        private static final String RESOURCE_ID = "35985678-0d79-46b4-9ed6-6f13308a1d24";
        private static final String BASE_URL = "https://api.data.gov.in/resource/" + RESOURCE_ID;

        @GetMapping
        public ResponseEntity<?> getMarketPrices(
                        @RequestParam(defaultValue = "Maharashtra") String state,
                        @RequestParam(defaultValue = "") String commodity,
                        @RequestParam(defaultValue = "100") int limit) {
                try {
                        // ✅ Capital S — field name "State" आहे
                        String encodedState = java.net.URLEncoder.encode(state, "UTF-8");
                        StringBuilder url = new StringBuilder(BASE_URL)
                                        .append("?api-key=").append(apiKey)
                                        .append("&format=json")
                                        .append("&limit=").append(limit)
                                        .append("&filters%5BState%5D=").append(encodedState);

                        if (!commodity.isBlank()) {
                                url.append("&filters%5BCommodity%5D=")
                                                .append(java.net.URLEncoder.encode(commodity, "UTF-8"));
                        }

                        System.out.println("Calling API...");

                        HttpClient client = HttpClient.newBuilder()
                                        .connectTimeout(java.time.Duration.ofSeconds(15))
                                        .build();
                        HttpRequest request = HttpRequest.newBuilder()
                                        .uri(URI.create(url.toString()))
                                        .header("Accept", "application/json")
                                        .GET()
                                        .build();

                        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
                        System.out.println("Status: " + response.statusCode());

                        if (response.statusCode() == 200) {
                                return ResponseEntity.ok()
                                                .header("Content-Type", "application/json")
                                                .body(response.body());
                        }
                        return ResponseEntity.status(response.statusCode())
                                        .body(Map.of("success", false, "message",
                                                        "API error: " + response.statusCode()));

                } catch (Exception e) {
                        e.printStackTrace();
                        return ResponseEntity.status(500).body(Map.of("success", false, "message", e.getMessage()));
                }
        }

        @GetMapping("/debug")
        public ResponseEntity<?> debug() {
                try {
                        String url = BASE_URL + "?api-key=" + apiKey + "&format=json&limit=3";
                        HttpClient client = HttpClient.newHttpClient();
                        HttpResponse<String> response = client.send(
                                        HttpRequest.newBuilder().uri(URI.create(url)).GET().build(),
                                        HttpResponse.BodyHandlers.ofString());
                        return ResponseEntity.ok(Map.of("status", response.statusCode(), "body", response.body()));
                } catch (Exception e) {
                        return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
                }
        }

        @GetMapping("/test-filter")
        public ResponseEntity<?> testFilter(@RequestParam String state) {
                try {
                        String encodedState = java.net.URLEncoder.encode(state, "UTF-8");
                        String url = BASE_URL + "?api-key=" + apiKey + "&format=json&limit=5"
                                        + "&filters%5BState%5D=" + encodedState;
                        HttpClient client = HttpClient.newHttpClient();
                        HttpResponse<String> response = client.send(
                                        HttpRequest.newBuilder().uri(URI.create(url)).GET().build(),
                                        HttpResponse.BodyHandlers.ofString());
                        return ResponseEntity.ok(Map.of(
                                        "status", response.statusCode(),
                                        "url_used", url.replace(apiKey, "***"),
                                        "body", response.body()));
                } catch (Exception e) {
                        return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
                }
        }

        @GetMapping("/states")
        public ResponseEntity<?> getStates() {
                return ResponseEntity.ok(Map.of("success", true, "data", Arrays.asList(
                                "Maharashtra", "Gujarat", "Punjab", "Haryana", "Uttar Pradesh",
                                "Madhya Pradesh", "Rajasthan", "Karnataka", "Andhra Pradesh",
                                "Tamil Nadu", "West Bengal", "Bihar")));
        }
}