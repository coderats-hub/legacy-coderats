// Arquivo: users/api/dto/UserUpdateDTO.java
package dev.coderats.backend.users.api.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.validation.constraints.Size;

// DTO para o request do PATCH /me (Schema UserUpdate)
public record UserUpdateDTO(
    @Size(min = 2, max = 255)
    String name,
    
    String image, // URI, mas String aqui para validação mais simples
    
    @JsonProperty("github_user")
    String githubUser
) {}

// Arquivo: users/api/dto/PrivateUserProfileDTO.java
