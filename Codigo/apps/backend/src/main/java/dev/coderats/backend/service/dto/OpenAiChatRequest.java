package dev.coderats.backend.service.dto;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

public record OpenAiChatRequest(
        String model,
        double temperature,
        @JsonProperty("response_format")
        ResponseFormat responseFormat,
        List<Message> messages
) {

    public static OpenAiChatRequest commitEvaluation(String model, String systemPrompt, String commitsPayload) {
        return new OpenAiChatRequest(
                model,
                0,
                new ResponseFormat("json_object"),
                List.of(
                        new Message("system", systemPrompt),
                        new Message("user", commitsPayload)
                )
        );
    }

    public record ResponseFormat(String type) {}

    public record Message(String role, String content) {}
}
