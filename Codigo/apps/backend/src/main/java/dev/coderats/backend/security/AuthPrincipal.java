package dev.coderats.backend.security;

import java.util.UUID;

public record AuthPrincipal(UUID userId, String githubUser) {}
