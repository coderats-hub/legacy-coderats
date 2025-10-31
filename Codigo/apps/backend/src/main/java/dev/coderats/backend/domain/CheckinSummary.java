package dev.coderats.backend.domain;

import java.time.OffsetDateTime;
import java.util.UUID;

public record CheckinSummary(
    UUID id,
    String description, 
    OffsetDateTime checkinDate,
    UUID userId,      
    String userName     
) {
}