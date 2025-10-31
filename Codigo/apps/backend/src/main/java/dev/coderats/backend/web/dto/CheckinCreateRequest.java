package dev.coderats.backend.web.dto;

public record CheckinCreateRequest(
    String title,
    String description,
    String image,
    String summary_ai
) {}
