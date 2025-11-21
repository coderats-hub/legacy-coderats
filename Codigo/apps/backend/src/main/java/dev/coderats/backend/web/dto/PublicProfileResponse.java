package dev.coderats.backend.web.dto;

import java.util.List;
import java.util.UUID;

// Resposta com dados públicos (sem email)
public record PublicProfileResponse(
    UUID id,
    String name,
    String image,
    List<CommonGroupSummary> commonGroups
) {}