package dev.coderats.backend.badges.api.dto;

import java.util.UUID;

public record BadgeDTO(
    UUID id,
    String name,
    String image,
    String description,
    int points
) {}