package dev.coderats.backend.checkins.app.query;

public record CommitView(
    String id,
    String link,
    String title,
    String hash
) {}