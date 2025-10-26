package dev.coderats.backend.checkins.api.dto;
import jakarta.validation.constraints.NotBlank;
public record CommentCreateDTO(@NotBlank String content) {}