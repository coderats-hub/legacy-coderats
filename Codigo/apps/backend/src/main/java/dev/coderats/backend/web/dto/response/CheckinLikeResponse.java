package dev.coderats.backend.web.dto.response;

public record CheckinLikeResponse(
    int likesCount,
    boolean userHasLiked
) {}
