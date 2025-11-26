package dev.coderats.backend.web.dto.response;

public record AuthResponse(UserDTO user, String token) {}
