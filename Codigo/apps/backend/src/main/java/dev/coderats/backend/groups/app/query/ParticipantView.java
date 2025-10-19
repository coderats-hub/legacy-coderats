package dev.coderats.backend.groups.app.query;

import dev.coderats.backend.users.domain.UserId;

// Retorna uma visão resumida de um participante do grupo.
public record ParticipantView(
        UserId id,
        String name,
        String image,
        int pointsInGroup
) {}