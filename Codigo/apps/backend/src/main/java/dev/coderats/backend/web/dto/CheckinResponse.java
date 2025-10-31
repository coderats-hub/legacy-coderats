package dev.coderats.backend.web.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

import dev.coderats.backend.domain.UserSummary;

public record CheckinResponse(
    UUID id,
    String title,
    String description,
    String image,
    String summary_ai,
    int points,
    OffsetDateTime createdAt,
    UserSummary author
) {}
