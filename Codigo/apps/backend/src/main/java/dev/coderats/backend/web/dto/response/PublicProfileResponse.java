package dev.coderats.backend.web.dto.response;

import java.util.List;
import java.util.UUID;

import dev.coderats.backend.web.dto.utils.CommonGroupSummary;

// Resposta com dados públicos (sem email)
public record PublicProfileResponse(
    UUID id,
    String name,
    String image,
    List<CommonGroupSummary> commonGroups
) {}