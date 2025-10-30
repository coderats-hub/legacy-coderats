package dev.coderats.backend.web.dto;

public record AuthResponse(PrivateUserResponse user, String token) {}
