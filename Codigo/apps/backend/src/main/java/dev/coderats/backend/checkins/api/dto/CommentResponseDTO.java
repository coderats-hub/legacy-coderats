package dev.coderats.backend.checkins.api.dto;

import java.util.UUID;

public record CommentResponseDTO(
    UUID id,
    String content,
    UserSummaryDTO author
) {}