package dev.coderats.backend.domain;

import java.time.OffsetDateTime;
import java.util.UUID;

public record CheckinSummary(
    UUID id,
    String title,
    OffsetDateTime createdAt,
    UserSummary author
) {
}
