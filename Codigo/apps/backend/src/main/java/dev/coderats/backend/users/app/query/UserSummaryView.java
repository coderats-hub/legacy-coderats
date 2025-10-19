package dev.coderats.backend.users.app.query;

public record UserSummaryView(
    String id,
    String name,
    String image
) {}