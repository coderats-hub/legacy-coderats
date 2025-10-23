package dev.coderats.backend.users.api.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.validation.constraints.Size;

public record UserUpdateDTO(
    @Size(min = 2, max = 255)
    String name,
    
    String image,
    
    @JsonProperty("github_user")
    String githubUser
) {}

