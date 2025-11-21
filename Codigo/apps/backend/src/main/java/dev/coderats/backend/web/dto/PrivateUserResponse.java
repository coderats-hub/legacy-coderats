package dev.coderats.backend.web.dto;

import java.util.UUID;

public record PrivateUserResponse(
  UUID id, String name, String email, String image, String github_user, Long github_id
) {}
