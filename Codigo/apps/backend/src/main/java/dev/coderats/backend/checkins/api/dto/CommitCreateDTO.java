package dev.coderats.backend.checkins.api.dto;
import jakarta.validation.constraints.NotBlank;
public record CommitCreateDTO(
    @NotBlank String link,
    @NotBlank String title,
    @NotBlank String hash
) {}