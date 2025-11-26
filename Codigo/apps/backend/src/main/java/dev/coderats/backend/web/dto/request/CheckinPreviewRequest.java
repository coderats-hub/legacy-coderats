package dev.coderats.backend.web.dto.request;

import java.util.List;

import java.util.UUID;

public record CheckinPreviewRequest(
        List<CommitSelectionRequest> commits,
        UUID userId
) {}
