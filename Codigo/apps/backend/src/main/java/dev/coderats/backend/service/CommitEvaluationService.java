package dev.coderats.backend.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ResponseStatusException;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import dev.coderats.backend.service.dto.GitHubCommitDetailPayload;
import dev.coderats.backend.web.dto.request.CommitSelectionRequest;

@Service
public class CommitEvaluationService {

    private static final Logger log = LoggerFactory.getLogger(CommitEvaluationService.class);

    private final GitHubCommitService gitHubCommitService;
    private final OpenAiEvaluationService openAiEvaluationService;
    private final ObjectMapper objectMapper;

    public CommitEvaluationService(
            GitHubCommitService gitHubCommitService,
            OpenAiEvaluationService openAiEvaluationService,
            ObjectMapper objectMapper) {
        this.gitHubCommitService = gitHubCommitService;
        this.openAiEvaluationService = openAiEvaluationService;
        this.objectMapper = objectMapper;
    }

    public EvaluationResult evaluate(UUID userId, List<CommitSelectionRequest> commits) {
        if (CollectionUtils.isEmpty(commits)) {
            log.debug("[CheckinPreview] Nenhum commit foi enviado para avaliacao do usuario {}", userId);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Nenhum commit selecionado.");
        }

        List<GitHubCommitDetailPayload> details = gitHubCommitService.fetchCommitDetails(userId, commits);
        if (details.isEmpty()) {
            log.debug("[CheckinPreview] Falha ao carregar detalhes dos commits {} para o usuario {}", commits, userId);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Não foi possível carregar os commits informados.");
        }

        log.debug("[CheckinPreview] Iniciando avaliacao de {} commits para o usuario {}", details.size(), userId);
        String payload = serialize(details);
        var agentResult = openAiEvaluationService.evaluate(payload);
        String summary = StringUtils.hasText(agentResult.summary_ai())
                ? agentResult.summary_ai()
                : "Resumo indisponível.";
        return new EvaluationResult(summary, agentResult.points());
    }

    private String serialize(List<GitHubCommitDetailPayload> details) {
        Map<String, Object> wrapper = new HashMap<>();
        wrapper.put("commits", details);
        try {
            return objectMapper.writeValueAsString(wrapper);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Falha ao gerar JSON de commits.", e);
        }
    }

    public record EvaluationResult(String summary, int points) {}
}

