package dev.coderats.backend.web.dto.response;

import java.time.OffsetDateTime;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * DTO unificado para retornar dados do usuário sem coleções LAZY.
 * Usado para evitar LazyInitializationException ao serializar entidades.
 * 
 * Substitui os DTOs redundantes:
 * - PrivateUserResponse (usado no AuthService)
 * - MyProfileResponse (usado no UserService)
 * 
 * Casos de uso:
 * - Resposta de autenticação (login GitHub)
 * - Perfil do usuário atual (/users/me)
 * - Atualização de perfil
 */
public record UserDTO(
    UUID id,
    String name,
    String email,
    String image,
    @JsonProperty("github_user") String githubUser,
    @JsonProperty("github_id") Long githubId,
    @JsonProperty("created_at") OffsetDateTime createdAt,
    @JsonProperty("updated_at") OffsetDateTime updatedAt
) {}
