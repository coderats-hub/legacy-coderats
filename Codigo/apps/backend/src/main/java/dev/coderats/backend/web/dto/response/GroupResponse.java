package dev.coderats.backend.web.dto.response;

import java.time.Instant;
import java.util.UUID;

public record GroupResponse(
    UUID id,
    String name,
    String description,
    String image,
    String method,
    Instant startDate,
    Instant endDate
) {}