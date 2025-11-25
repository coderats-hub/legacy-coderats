package dev.coderats.backend.service.dto;

public record BedrockAgentResult(
        int points,
        String summary,
        String rawResponse
) {}

