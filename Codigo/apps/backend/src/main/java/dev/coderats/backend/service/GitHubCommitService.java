package dev.coderats.backend.service;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.annotation.JsonProperty;

import dev.coderats.backend.infra.repository.UserRepository;
import dev.coderats.backend.web.dto.response.GitHubCommitResponse;

@Service
public class GitHubCommitService {

    private static final int MAX_PAGE_SIZE = 20;

    private final UserRepository userRepository;
    private final RestClient http;

    public GitHubCommitService(UserRepository userRepository) {
        this.userRepository = userRepository;
        this.http = RestClient.builder()
                .baseUrl("https://api.github.com")
                .defaultHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE)
                .defaultHeader(HttpHeaders.USER_AGENT, "coderats-backend")
                .build();
    }

    public List<GitHubCommitResponse> fetchRecentCommits(UUID userId, int page, int size) {
        var user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));

        if (!StringUtils.hasText(user.getGithubUser())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Usuário não possui GitHub vinculado");
        }

        int normalizedPage = Math.max(page, 1);
        int normalizedSize = Math.max(1, Math.min(size, MAX_PAGE_SIZE));
        int eventsPageSize = Math.min(30, normalizedSize * 3);

        String uri = UriComponentsBuilder.fromPath("/users/{login}/events")
                .queryParam("page", normalizedPage)
                .queryParam("per_page", eventsPageSize)
                .buildAndExpand(user.getGithubUser())
                .toUriString();

        List<GithubEvent> events;
        try {
            events = http.get()
                    .uri(uri)
                    .retrieve()
                    .body(new org.springframework.core.ParameterizedTypeReference<List<GithubEvent>>() {});
        } catch (RestClientException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Falha ao consultar eventos no GitHub", ex);
        }

        if (events == null || events.isEmpty()) {
            return List.of();
        }

        Map<String, GitHubCommitResponse> commits = new LinkedHashMap<>();

        outer: for (GithubEvent event : events) {
            if (!"PushEvent".equals(event.type()) || event.payload() == null || event.payload().commits() == null) {
                continue;
            }
            String repoName = event.repo() != null ? event.repo().name() : null;
            OffsetDateTime createdAt = event.createdAt();

            for (GithubCommit commit : event.payload().commits()) {
                if (!StringUtils.hasText(commit.sha())) {
                    continue;
                }
                commits.putIfAbsent(
                        commit.sha(),
                        new GitHubCommitResponse(
                                commit.sha(),
                                commit.message(),
                                repoName,
                                buildHtmlUrl(repoName, commit.sha()),
                                createdAt));

                if (commits.size() >= normalizedSize) {
                    break outer;
                }
            }
        }

        return new ArrayList<>(commits.values());
    }

    private String buildHtmlUrl(String repository, String sha) {
        if (!StringUtils.hasText(repository) || !StringUtils.hasText(sha)) {
            return null;
        }
        return "https://github.com/" + repository + "/commit/" + sha;
    }

    private record GithubEvent(
            String type,
            GithubRepo repo,
            GithubPayload payload,
            @JsonProperty("created_at") OffsetDateTime createdAt) {
    }

    private record GithubRepo(String name) {
    }

    private record GithubPayload(List<GithubCommit> commits) {
    }

    private record GithubCommit(String sha, String message) {
    }
}
