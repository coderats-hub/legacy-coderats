package dev.coderats.backend.users.api.dto;

import java.util.UUID;

public record GroupSummaryDTO(
    UUID id,
    String name,
    boolean status,
    String image
) {}