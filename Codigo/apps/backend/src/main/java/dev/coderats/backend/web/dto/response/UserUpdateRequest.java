package dev.coderats.backend.web.dto.response;

// Campos que o usuário pode atualizar.
// null significa "não alterar".
public record UserUpdateRequest(
    String name,
    String image
) {}