package dev.coderats.backend.groups.api.dto;

import java.net.URI;
import java.time.Instant;
import java.util.UUID;

public record GroupResponseDTO(
    UUID id,
    String name,
    String description,
    String image,
    String code,
    String method,
    String status,
    URI repository,
    Instant startDate,
    Instant endDate,
    Instant createdAt
) {}