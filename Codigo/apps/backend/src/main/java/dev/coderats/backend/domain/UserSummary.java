package dev.coderats.backend.domain;

import java.util.UUID;

public record UserSummary(
    UUID id,
    String name,
    String image,
    String github_user,
    Double points,
    String role
) {}
