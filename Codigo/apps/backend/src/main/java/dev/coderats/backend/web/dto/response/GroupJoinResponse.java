package dev.coderats.backend.web.dto.response;

import java.time.Instant;

public record GroupJoinResponse(
    GroupResponse group,
    GroupJoinResponseMembership membership
) {
    public record GroupJoinResponseMembership(
        String role,
        Instant joinedAt
    ) {}
}
