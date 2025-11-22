package dev.coderats.backend.web.dto.response;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import dev.coderats.backend.domain.CheckinSummary;
import dev.coderats.backend.domain.UserSummary;

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