package dev.coderats.backend.users.api.dto;

import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonProperty;

public record PrivateUserProfileDTO(
    UUID id,
    String name,
    String email,
    String image,
    @JsonProperty("github_user")
    String githubUser
) {}