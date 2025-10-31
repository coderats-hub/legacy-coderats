package dev.coderats.backend.features.checkin;

public record CheckinCreateRequest(
    String title,
    String description,
    String image,
    String summary_ai
) {}
