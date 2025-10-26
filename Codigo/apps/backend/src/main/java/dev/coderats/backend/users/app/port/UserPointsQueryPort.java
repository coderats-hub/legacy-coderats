package dev.coderats.backend.users.app.port;

import dev.coderats.backend.users.domain.UserId;


// Porta para consultar pontos (que vêm de 'group_participants').
public interface UserPointsQueryPort {
    int getTotalPointsForUser(UserId userId);
}