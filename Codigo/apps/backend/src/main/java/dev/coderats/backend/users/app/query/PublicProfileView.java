package dev.coderats.backend.users.app.query;

public record PublicProfileView(
    String id,
    String name,
    String image,
    String githubUser,
    int points
) {}