package dev.coderats.backend.web.dto.response;

import java.time.OffsetDateTime;
import java.util.UUID;

// Resposta com dados privados (email, githubId)
public record MyProfileResponse(
    UUID id,
    String name,
    String email,
    String image,
    String githubId,
    OffsetDateTime createdAt
) {}