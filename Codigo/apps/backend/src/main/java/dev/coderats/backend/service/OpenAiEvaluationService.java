package dev.coderats.backend.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import dev.coderats.backend.web.dto.response.OpenAiEvaluationResponse;

@Service
public class OpenAiEvaluationService {

    private static final Logger log = LoggerFactory.getLogger(OpenAiEvaluationService.class);

    private final OpenAiClient openAiClient;

    public OpenAiEvaluationService(OpenAiClient openAiClient) {
        this.openAiClient = openAiClient;
    }

    public OpenAiEvaluationResponse evaluate(String payload) {
        if (!openAiClient.isConfigured()) {
            log.warn("OpenAI não configurada. Retornando resposta padrão para prévia.");
            return new OpenAiEvaluationResponse(
                    0,
                    "Prévia indisponível: OpenAI não configurada.",
                    "{\"summary\":\"OpenAI não configurada\",\"points\":0}"
            );
        }
        return openAiClient.evaluateCommits(payload);
    }
}
