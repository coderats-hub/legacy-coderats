package dev.coderats.backend.service.dto;

import java.time.OffsetDateTime;
import java.util.List;

public record GitHubCommitDetailPayload(
        String repository,
        String sha,
        String message,
        String htmlUrl,
        OffsetDateTime committedAt,
        Author author,
        Stats stats,
        List<File> files
) {

    public record Author(
            String name,
            String email,
            OffsetDateTime date
    ) {}

    public record Stats(
            int additions,
            int deletions,
            int total
    ) {}

    public record File(
            String filename,
            String status,
            int additions,
            int deletions,
            int changes,
            String patch,
            String rawUrl,
            String blobUrl
    ) {}
}

