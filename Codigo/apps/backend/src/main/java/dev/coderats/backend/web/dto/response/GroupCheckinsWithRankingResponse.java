package dev.coderats.backend.web.dto.response;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public record GroupCheckinsWithRankingResponse(
        UUID id,
        String name,
        String description,
        String image,
        String code,
        String repository,
        String method,
        boolean status,
        OffsetDateTime start_date,
        OffsetDateTime end_date,
        OffsetDateTime created_at,
        OffsetDateTime updated_at,
        List<CheckinResponse> checkins_recentes,
        List<GroupRankingItem> ranking
) {
    public record GroupRankingItem(
            UUID id,
            String name,
            String image,
            String github_user,
            Double points,
            String role
    ) {}
}
