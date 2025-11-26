package dev.coderats.backend.web.dto.response;

import java.time.OffsetDateTime;
import java.util.UUID;

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
    String githubUser,
    Long githubId,
    OffsetDateTime createdAt,
    OffsetDateTime updatedAt
) {}
