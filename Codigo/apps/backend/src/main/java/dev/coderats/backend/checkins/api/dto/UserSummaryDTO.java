package dev.coderats.backend.checkins.api.dto;

import java.util.UUID;

public record UserSummaryDTO(
    UUID id,
    String name,
    String image
) {}