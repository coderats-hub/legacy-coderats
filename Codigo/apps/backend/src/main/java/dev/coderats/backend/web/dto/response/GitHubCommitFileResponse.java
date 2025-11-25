package dev.coderats.backend.web.dto.response;

public record GitHubCommitFileResponse(
        String filename,
        String status,
        int additions,
        int deletions,
        int changes,
        String patch,
        String rawUrl,
        String blobUrl) {
}

