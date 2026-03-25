package com.agriconnect.backend.service;

import com.agriconnect.backend.dto.ChatRequest;
import com.agriconnect.backend.dto.ChatResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

@Service
public class ChatService {

    @Value("${groq.api.key:}")
    private String apiKey;

    @Value("${groq.api.url:}")
    private String apiUrl;

    private WebClient webClient;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @PostConstruct
    public void init() {
        System.out.println("🔧 Initializing ChatService...");
        System.out.println("📌 API URL: " + (apiUrl.isEmpty() ? "NOT FOUND" : apiUrl));

        if (apiKey.isEmpty()) {
            throw new RuntimeException("❌ Groq API key is missing! Please configure it.");
        }

        String finalApiUrl = apiUrl.isEmpty()
                ? "https://api.groq.com/openai/v1/chat/completions"
                : apiUrl;

        this.webClient = WebClient.builder()
                .baseUrl(finalApiUrl)
                .defaultHeader("Content-Type", "application/json")
                .defaultHeader("Authorization", "Bearer " + apiKey)
                .build();

        System.out.println("✅ ChatService initialized successfully");
    }

    public ChatResponse processMessage(ChatRequest request) {
        try {
            String prompt = createPrompt(request);
            String response = callGroqAPI(prompt);
            return new ChatResponse(response);
        } catch (Exception e) {
            return new ChatResponse(getFallbackResponse(request.getLanguage()));
        }
    }

    private String createPrompt(ChatRequest request) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("You are AgriAssist, a helpful assistant for Agri Connect platform. ");
        prompt.append("Keep responses short and helpful. ");

        prompt.append("\nUser message: ").append(request.getMessage());
        return prompt.toString();
    }

    private String callGroqAPI(String prompt) {
        try {
            Map<String, Object> requestBody = Map.of(
                    "model", "mixtral-8x7b-32768",
                    "messages", List.of(Map.of("role", "user", "content", prompt)),
                    "temperature", 0.7,
                    "max_tokens", 500);

            String responseJson = webClient.post()
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            JsonNode root = objectMapper.readTree(responseJson);
            return root.path("choices").get(0).path("message").path("content").asText();

        } catch (Exception e) {
            return "Service unavailable. Try again later.";
        }
    }

    private String getFallbackResponse(String language) {
        return "Service unavailable. Try again later.";
    }
}