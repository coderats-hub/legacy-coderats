package dev.coderats.backend.groups.app.command;

import dev.coderats.backend.groups.domain.GroupId;
import dev.coderats.backend.users.domain.UserId;

// Define o que é necessário para deletar um grupo.
public record DeleteGroupCommand(
        GroupId groupId,
        UserId deleterId
) {}