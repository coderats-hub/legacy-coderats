package dev.coderats.backend.groups.app.command;
import java.net.URI;
import java.time.Instant;

import dev.coderats.backend.groups.domain.GroupMethod;
import dev.coderats.backend.groups.domain.GroupStatus;
import dev.coderats.backend.users.domain.UserId;

// Define o que é necessário para criar um grupo, espelhando o 'GroupCreate' da OpenAPI.
public record CreateGroupCommand(
        String name,
        String description,
        String image,
        String code,
        GroupMethod method,
        GroupStatus status,
        URI repository,
        Instant startDate,
        Instant endDate,
        UserId creatorId
) {}