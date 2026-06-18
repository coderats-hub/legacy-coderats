package dev.coderats.backend.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import dev.coderats.backend.web.dto.request.OpenAiChatRequest;
import dev.coderats.backend.web.dto.response.OpenAiChatResponse;
import dev.coderats.backend.web.dto.response.OpenAiEvaluationResponse;

@Service
public class OpenAiClient {

    private static final Logger log = LoggerFactory.getLogger(OpenAiClient.class);

    private final RestClient restClient;
    private final ObjectMapper objectMapper;
    private final String apiKey;
    private final String endpoint;
    private final String model;
    private final String systemPrompt;

    public OpenAiClient(
            RestClient.Builder restClientBuilder,
            ObjectMapper objectMapper,
            @Value("${openai.base-url:https://api.openai.com/v1}") String baseUrl,
            @Value("${openai.chat-endpoint:/chat/completions}") String chatEndpoint,
            @Value("${openai.model:gpt-4.1-mini}") String model,
            @Value("${openai.system-prompt:}") String systemPrompt,
            @Value("${OPENAI_API_KEY:}") String apiKey) {
        this.restClient = restClientBuilder
                .baseUrl(baseUrl)
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .build();
        this.objectMapper = objectMapper;
        this.apiKey = apiKey;
        this.endpoint = chatEndpoint;
        this.model = model;
        this.systemPrompt = StringUtils.hasText(systemPrompt)
            ? systemPrompt
            : "Você é um agente especializado em analisar um conjunto de commits enviados pela API do GitHub. Você pode receber um único commit ou vários commits de uma só vez.\n\n"
              + "Cada commit chega em formato JSON contendo: autor, mensagem, estatísticas (additions, deletions, total), arquivos modificados, patch unificado (diff) e informações adicionais. Avalie apenas o que estiver presente. Nunca invente dados.\n\n"
              + "Sua tarefa:\n\n"
              + "1. Validar os commits:\n"
              + "   - verificar diffs bem-formados\n"
              + "   - verificar campos obrigatórios\n"
              + "   - verificar coerência geral\n\n"
              + "2. Avaliar tecnicamente o conjunto completo, seguindo esta ordem de importância:\n"
              + "   (1) quantidade e proporção de linhas adicionadas (peso maior para additions)\n"
              + "   (2) complexidade e qualidade do código modificado/criado\n"
              + "   (3) quantidade de commits no conjunto\n\n"
              + "3. Com base nisso, gerar uma nota final entre 0 e 10.\n\n"
              + "4. Gerar um pequeno resumo descrevendo objetivamente o que o conjunto representa (ex.: adicionou funcionalidade, corrigiu bug, refatorou, etc.). Nunca invente arquivos ou mudanças além do que recebeu.\n\n"
              + "A resposta DEVE ser APENAS um JSON com:{\n"
              + "  \"points\": número inteiro de 0 a 10,\n"
              + "  \"summary_ai\": \"texto curto\"\n"
              + "}";
    }

    public boolean isConfigured() {
        return StringUtils.hasText(apiKey) && StringUtils.hasText(systemPrompt);
    }

    public OpenAiEvaluationResponse evaluateCommits(String payload) {
        if (!isConfigured()) {
            throw new IllegalStateException("OpenAI API key ou system prompt não configurados.");
        }
        OpenAiChatRequest request = OpenAiChatRequest.commitEvaluation(model, systemPrompt, payload);
        try {
            OpenAiChatResponse response = restClient.post()
                    .uri(endpoint)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                    .body(request)
                    .retrieve()
                    .body(OpenAiChatResponse.class);

            return extractEvaluation(response);
        } catch (RestClientResponseException ex) {
            log.error("Falha HTTP ao chamar a OpenAI: status={} body={}", ex.getStatusCode(), ex.getResponseBodyAsString());
            throw new IllegalStateException("Erro ao chamar a API da OpenAI.", ex);
        } catch (Exception ex) {
            throw new IllegalStateException("Erro ao processar a resposta da OpenAI.", ex);
        }
    }

    private OpenAiEvaluationResponse extractEvaluation(OpenAiChatResponse response) {
        if (response == null || CollectionUtils.isEmpty(response.choices())) {
            throw new IllegalStateException("Resposta vazia da OpenAI.");
        }
        OpenAiChatResponse.Choice choice = response.choices().get(0);
        if (choice == null || choice.message() == null || !StringUtils.hasText(choice.message().content())) {
            throw new IllegalStateException("Mensagem vazia retornada pela OpenAI.");
        }
        String content = choice.message().content().trim();
        try {
            JsonNode node = objectMapper.readTree(content);
            int points = node.path("points").asInt(0);
            String summary = node.path("summary_ai").asText(null);
            if (!StringUtils.hasText(summary)) {
                summary = node.path("summary").asText("");
            }
            return new OpenAiEvaluationResponse(points, summary, content);
        } catch (Exception ex) {
            throw new IllegalStateException("Resposta inválida retornada pela OpenAI: " + content, ex);
        }
    }
}
