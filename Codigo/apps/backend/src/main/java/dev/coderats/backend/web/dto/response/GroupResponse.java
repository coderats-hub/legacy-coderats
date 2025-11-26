package dev.coderats.backend.web.dto.response;

import java.time.OffsetDateTime;
import java.util.UUID;

public record GroupResponse(
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
    OffsetDateTime updated_at
) {}
