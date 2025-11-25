package dev.coderats.backend.service;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
import dev.coderats.backend.web.dto.response.GitHubCommitFileResponse;
import dev.coderats.backend.web.dto.response.GitHubCommitResponse;

@Service
public class GitHubCommitService {

    private static final int MAX_PAGE_SIZE = 20;
    private static final Logger log = LoggerFactory.getLogger(GitHubCommitService.class);

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
        if (!StringUtils.hasText(user.getGithubAccessToken())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Token do GitHub indisponível. Faça login novamente.");
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
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + user.getGithubAccessToken())
                    .retrieve()
                    .body(new org.springframework.core.ParameterizedTypeReference<List<GithubEvent>>() {});
        } catch (RestClientException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Falha ao consultar eventos no GitHub", ex);
        }

        if (events == null || events.isEmpty()) {
            return List.of();
        }

        Map<String, GitHubCommitResponse> commits = new LinkedHashMap<>();
        OffsetDateTime threshold = OffsetDateTime.now(ZoneOffset.UTC).minusHours(48);

        outer: for (GithubEvent event : events) {
            if (!"PushEvent".equals(event.type()) || event.payload() == null) {
                continue;
            }
            String repoName = event.repo() != null ? event.repo().name() : null;
            OffsetDateTime createdAt = event.createdAt();
            if (createdAt == null || createdAt.isBefore(threshold) || !StringUtils.hasText(repoName)) {
                continue;
            }

            List<GithubCommit> eventCommits = extractCommits(event);
            if (eventCommits.isEmpty()) {
                continue;
            }

            for (GithubCommit commit : eventCommits) {
                if (!StringUtils.hasText(commit.sha())) {
                    continue;
                }
                GithubCommitDetail detail = fetchCommitDetail(repoName, commit.sha(), user.getGithubAccessToken());
                commits.putIfAbsent(
                        commit.sha(),
                        new GitHubCommitResponse(
                                commit.sha(),
                                resolveMessage(commit, detail),
                                repoName,
                                resolveHtmlUrl(repoName, commit.sha(), detail),
                                resolveCommittedAt(createdAt, detail),
                                mapFiles(detail)));

                if (commits.size() >= normalizedSize) {
                    break outer;
                }
            }
        }

        return new ArrayList<>(commits.values());
    }

    private List<GithubCommit> extractCommits(GithubEvent event) {
        if (event.payload() == null) {
            return List.of();
        }
        if (event.payload().commits() != null && !event.payload().commits().isEmpty()) {
            return event.payload().commits();
        }
        if (StringUtils.hasText(event.payload().head())) {
            return List.of(new GithubCommit(event.payload().head(), null));
        }
        return List.of();
    }

    private String buildHtmlUrl(String repository, String sha) {
        if (!StringUtils.hasText(repository) || !StringUtils.hasText(sha)) {
            return null;
        }
        return "https://github.com/" + repository + "/commit/" + sha;
    }

    private GithubCommitDetail fetchCommitDetail(String repository, String sha, String token) {
        if (!StringUtils.hasText(repository) || !StringUtils.hasText(sha)) {
            return null;
        }
        try {
            return http.get()
                    .uri("/repos/{repository}/commits/{sha}", repository, sha)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                    .retrieve()
                    .body(GithubCommitDetail.class);
        } catch (RestClientException ex) {
            log.debug("Falha ao obter detalhes do commit {} em {}: {}", sha, repository, ex.getMessage());
            return null;
        }
    }

    private String resolveMessage(GithubCommit commit, GithubCommitDetail detail) {
        if (detail != null && detail.commit() != null && StringUtils.hasText(detail.commit().message())) {
            return detail.commit().message();
        }
        return commit.message();
    }

    private String resolveHtmlUrl(String repository, String sha, GithubCommitDetail detail) {
        if (detail != null && StringUtils.hasText(detail.htmlUrl())) {
            return detail.htmlUrl();
        }
        return buildHtmlUrl(repository, sha);
    }

    private OffsetDateTime resolveCommittedAt(OffsetDateTime fallback, GithubCommitDetail detail) {
        if (detail != null && detail.commit() != null && detail.commit().author() != null
                && detail.commit().author().date() != null) {
            return detail.commit().author().date();
        }
        return fallback;
    }

    private List<GitHubCommitFileResponse> mapFiles(GithubCommitDetail detail) {
        if (detail == null || detail.files() == null || detail.files().isEmpty()) {
            return List.of();
        }
        return detail.files().stream()
                .map(f -> new GitHubCommitFileResponse(
                        f.filename(),
                        f.status(),
                        f.additions(),
                        f.deletions(),
                        f.changes(),
                        f.patch(),
                        f.rawUrl(),
                        f.blobUrl()))
                .collect(Collectors.toList());
    }

    private record GithubEvent(
            String type,
            GithubRepo repo,
            GithubPayload payload,
            @JsonProperty("created_at") OffsetDateTime createdAt) {
    }

    private record GithubRepo(String name) {
    }

    private record GithubPayload(List<GithubCommit> commits, String head) {
    }

    private record GithubCommit(String sha, String message) {
    }

    private record GithubCommitDetail(
            @JsonProperty("html_url") String htmlUrl,
            GithubCommitInfo commit,
            List<GithubCommitFile> files) {
    }

    private record GithubCommitInfo(
            String message,
            GithubCommitAuthor author) {
    }

    private record GithubCommitAuthor(OffsetDateTime date) {
    }

    private record GithubCommitFile(
            String filename,
            String status,
            int additions,
            int deletions,
            int changes,
            String patch,
            @JsonProperty("raw_url") String rawUrl,
            @JsonProperty("blob_url") String blobUrl) {
    }
}
