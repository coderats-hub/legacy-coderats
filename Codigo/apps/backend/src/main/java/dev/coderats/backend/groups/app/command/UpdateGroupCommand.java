package dev.coderats.backend.groups.app.command;

import java.net.URI;
import java.util.List;

import dev.coderats.backend.groups.domain.GroupId;
import dev.coderats.backend.users.domain.UserId;

// Define o que é necessário para atualizar um grupo, espelhando o 'GroupUpdate' da OpenAPI.
public record UpdateGroupCommand(
        GroupId groupId,
        UserId updaterId,
        String name,
        String description,
        String image,
        URI repository,
        List<UserId> participantsRemove
) {}