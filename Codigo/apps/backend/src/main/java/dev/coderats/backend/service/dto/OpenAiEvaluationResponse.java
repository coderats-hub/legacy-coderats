package dev.coderats.backend.service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record OpenAiEvaluationResponse(
        int points,
        @JsonProperty("summary_ai")
        String summary_ai,
        String rawResponse
) {}
