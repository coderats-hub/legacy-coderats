package dev.coderats.backend.users.api.dto;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

public record PublicUserProfileWithGroupsDTO(
    PublicUserProfileDTO profile,
    @JsonProperty("common_groups")
    List<GroupSummaryDTO> commonGroups
) {}