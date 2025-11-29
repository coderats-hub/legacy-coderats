package dev.coderats.backend.web.dto.response;

import java.util.UUID;

public record ImageUploadResponse(
    String url,
    String key,
    String targetType,
    UUID entityId
) { }
