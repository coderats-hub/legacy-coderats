package dev.coderats.backend.features.group;

import java.time.OffsetDateTime;

public record GroupCreateRequest(
    String name,
    OffsetDateTime start_date,
    OffsetDateTime end_date,
    String description,
    String image,
    String code,
    String repository,
    String method
) {}
