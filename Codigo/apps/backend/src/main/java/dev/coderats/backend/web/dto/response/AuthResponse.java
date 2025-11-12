package dev.coderats.backend.web.dto.response;

public record AuthResponse(PrivateUserResponse user, String token) {}
