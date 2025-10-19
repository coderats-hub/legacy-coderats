package dev.coderats.backend.users.app.command;

import dev.coderats.backend.users.domain.UserId;

public record UpdateMeCommand(
    UserId userIdToUpdate,
    String name,
    String image,
    String githubUser
) {}