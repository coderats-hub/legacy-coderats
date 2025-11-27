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

import dev.coderats.backend.domain.User;
import dev.coderats.backend.infra.repository.UserRepository;
import dev.coderats.backend.service.dto.GitHubCommitDetailPayload;
import dev.coderats.backend.web.dto.request.CommitSelectionRequest;
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
        return fetchCommits(userId, page, size, 48, null);
    }

    public List<GitHubCommitResponse> fetchRecentCommitsForRepository(
            UUID userId,
            int page,
            int size,
            int thresholdHours,
            String repository) {
        if (!StringUtils.hasText(repository)) {
            return List.of();
        }
        return fetchCommits(userId, page, size, thresholdHours, repository.trim());
    }

    private List<GitHubCommitResponse> fetchCommits(
            UUID userId,
            int page,
            int size,
            int thresholdHours,
            String repositoryFilter) {
        var user = requireGithubUser(userId);

        int normalizedPage = Math.max(page, 1);
        int normalizedSize = Math.max(1, Math.min(size, MAX_PAGE_SIZE));
        int eventsPageSize = Math.min(30, normalizedSize * 3);
        int effectiveHours = thresholdHours > 0 ? thresholdHours : 48;

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
        OffsetDateTime threshold = OffsetDateTime.now(ZoneOffset.UTC).minusHours(effectiveHours);
        String normalizedRepository = repositoryFilter != null ? repositoryFilter.trim() : null;

        outer: for (GithubEvent event : events) {
            if (!"PushEvent".equals(event.type()) || event.payload() == null) {
                continue;
            }
            String repoName = event.repo() != null ? event.repo().name() : null;
            OffsetDateTime createdAt = event.createdAt();
            if (createdAt == null || createdAt.isBefore(threshold) || !StringUtils.hasText(repoName)) {
                continue;
            }
            if (StringUtils.hasText(normalizedRepository)
                    && !normalizedRepository.equalsIgnoreCase(repoName)) {
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

    public List<GitHubCommitDetailPayload> fetchCommitDetails(UUID userId, List<CommitSelectionRequest> commits) {
        var user = requireGithubUser(userId);
        if (commits == null || commits.isEmpty()) {
            return List.of();
        }

        List<GitHubCommitDetailPayload> results = new ArrayList<>();
        String maskedToken = maskToken(user.getGithubAccessToken());
        log.debug("[GitHubCommit] Preparando busca de {} commits para usuario={} token={}", commits.size(), user.getGithubUser(), maskedToken);
        for (CommitSelectionRequest commit : commits) {
            if (commit == null || !StringUtils.hasText(commit.repository()) || !StringUtils.hasText(commit.sha())) {
                continue;
            }
            String sanitizedToken = sanitize(user.getGithubAccessToken());
            GithubCommitDetail detail = fetchCommitDetail(commit.repository(), commit.sha(), sanitizedToken);
            if (detail != null) {
                results.add(toPayload(commit.repository(), commit.sha(), detail));
            }
        }
        return results;
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

    private User requireGithubUser(UUID userId) {
        var user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));
        if (!StringUtils.hasText(user.getGithubUser())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Usuário não possui GitHub vinculado");
        }
        if (!StringUtils.hasText(user.getGithubAccessToken())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Token do GitHub indisponível. Faça login novamente.");
        }
        return user;
    }

    private GithubCommitDetail fetchCommitDetail(String repository, String sha, String token) {
        if (!StringUtils.hasText(repository) || !StringUtils.hasText(sha)) {
            return null;
        }
        var repo = splitRepository(repository);
        if (repo == null) {
            log.debug("Repositorio invalido '{}' - esperado owner/repo", repository);
            return null;
        }
        String effectiveToken = sanitize(token);
        try {
            return http.get()
                    .uri("/repos/{owner}/{repo}/commits/{sha}", repo.owner(), repo.repo(), sha)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + effectiveToken)
                    .retrieve()
                    .body(GithubCommitDetail.class);
        } catch (RestClientException ex) {
            log.debug("Falha ao obter detalhes do commit {} em {}: {}", sha, repository, ex.getMessage());
            return null;
        }
    }

    private RepoRef splitRepository(String repository) {
        String sanitized = repository.trim();
        int slash = sanitized.indexOf('/');
        if (slash <= 0 || slash == sanitized.length() - 1) {
            return null;
        }
        return new RepoRef(sanitized.substring(0, slash), sanitized.substring(slash + 1));
    }

    private record RepoRef(String owner, String repo) {}

    private String sanitize(String token) {
        return token != null ? token.trim() : null;
    }

    private String maskToken(String token) {
        if (!StringUtils.hasText(token)) {
            return "null";
        }
        String sanitized = sanitize(token);
        int length = sanitized != null ? sanitized.length() : 0;
        String prefix = sanitized != null ? sanitized.substring(0, Math.min(6, sanitized.length())) : "";
        return prefix + "...(" + length + ")";
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

    private GitHubCommitDetailPayload toPayload(String repository, String sha, GithubCommitDetail detail) {
        var author = detail.commit() != null && detail.commit().author() != null
                ? new GitHubCommitDetailPayload.Author(
                        detail.commit().author().name(),
                        detail.commit().author().email(),
                        detail.commit().author().date())
                : null;
        var stats = detail.stats() != null
                ? new GitHubCommitDetailPayload.Stats(
                        detail.stats().additions(),
                        detail.stats().deletions(),
                        detail.stats().total())
                : null;

        return new GitHubCommitDetailPayload(
                repository,
                sha,
                detail.commit() != null ? detail.commit().message() : null,
                detail.htmlUrl(),
                detail.commit() != null && detail.commit().author() != null ? detail.commit().author().date() : null,
                author,
                stats,
                mapPayloadFiles(detail));
    }

    private List<GitHubCommitDetailPayload.File> mapPayloadFiles(GithubCommitDetail detail) {
        if (detail == null || detail.files() == null || detail.files().isEmpty()) {
            return List.of();
        }
        return detail.files().stream()
                .map(f -> new GitHubCommitDetailPayload.File(
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
            GithubCommitStats stats,
            List<GithubCommitFile> files) {
    }

    private record GithubCommitInfo(
            String message,
            GithubCommitAuthor author) {
    }

    private record GithubCommitAuthor(
            String name,
            String email,
            OffsetDateTime date) {
    }

    private record GithubCommitStats(
            int additions,
            int deletions,
            int total) {
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
