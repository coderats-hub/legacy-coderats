package dev.coderats.backend.features.checkin;

import dev.coderats.backend.features.group.UserSummary;
import java.time.OffsetDateTime;
import java.util.UUID;

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
