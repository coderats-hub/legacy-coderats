package dev.coderats.backend.groups.app.query;

import java.time.Instant;

import dev.coderats.backend.users.domain.UserId;

// Retorna uma visão resumida de um check-in em um grupo.
public record CheckinSummaryView(
        String id, 
        String title,
        Instant createdAt,
        UserId authorId,
        String authorName
) {}