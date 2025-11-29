package dev.coderats.backend.web.dto.request;

public record CommitSelectionRequest(
        String repository,
        String sha
) {}

