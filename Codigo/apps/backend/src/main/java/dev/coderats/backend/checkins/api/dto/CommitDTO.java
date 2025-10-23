package dev.coderats.backend.checkins.api.dto;

import java.util.UUID;

public record CommitDTO(
    UUID id,
    String link,
    String titulo,
    String hash
) {}