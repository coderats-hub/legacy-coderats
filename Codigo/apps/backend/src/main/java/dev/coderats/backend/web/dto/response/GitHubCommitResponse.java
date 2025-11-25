package dev.coderats.backend.web.dto.response;

import java.time.OffsetDateTime;
import java.util.List;

public record GitHubCommitResponse(
        String sha,
        String message,
        String repository,
        String url,
        OffsetDateTime committedAt,
        List<GitHubCommitFileResponse> files) {
}
