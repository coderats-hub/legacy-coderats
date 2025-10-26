package dev.coderats.backend.users.api.dto;

import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonProperty;

public record PublicUserProfileDTO(
    UUID id,
    String name,
    String image,
    @JsonProperty("github_user")
    String githubUser,
    int points
) {}