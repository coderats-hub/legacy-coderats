package dev.coderats.backend.web.dto.request;

import java.util.List;

public record CheckinPreviewRequest(
        List<CommitSelectionRequest> commits
) {}

