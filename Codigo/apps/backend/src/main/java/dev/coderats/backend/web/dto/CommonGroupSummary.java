package dev.coderats.backend.web.dto;

import java.util.UUID;

// Um resumo simples do grupo para a lista de "grupos em comum"
public record CommonGroupSummary(
    UUID id,
    String name,
    String image
) {}