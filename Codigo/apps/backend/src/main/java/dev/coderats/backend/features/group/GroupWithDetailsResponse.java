package dev.coderats.backend.features.group;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public record GroupWithDetailsResponse(
    UUID id,
    String name,
    String description,
    String image,
    String code,
    String repository,
    String method,
    Boolean status,
    OffsetDateTime start_date,
    OffsetDateTime end_date,
    OffsetDateTime created_at,
    OffsetDateTime updated_at,
    List<UserSummary> participants,
    List<CheckinSummary> recent_checkins
) {}

// Classe auxiliar para representar checkins resumidos
record CheckinSummary(
    UUID id,
    String title,
    OffsetDateTime createdAt,
    UserSummary author
) {}
