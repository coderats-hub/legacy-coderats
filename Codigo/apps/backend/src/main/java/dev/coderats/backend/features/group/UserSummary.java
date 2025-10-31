package dev.coderats.backend.features.group;

import java.util.UUID;

public record UserSummary(
    UUID id,
    String name,
    String image
) {}
