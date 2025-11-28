package dev.coderats.backend.web.dto.request;

import java.util.List;

public record CheckinCreateRequest(
    String title,
    String description,
    String image,
    String summary_ai,
    List<CommitSelectionRequest> commits
) {}
