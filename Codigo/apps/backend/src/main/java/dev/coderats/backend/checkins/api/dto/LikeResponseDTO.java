package dev.coderats.backend.checkins.api.dto;

import java.util.UUID;

public record LikeResponseDTO(
    UUID id,
    UserSummaryDTO author
) {}