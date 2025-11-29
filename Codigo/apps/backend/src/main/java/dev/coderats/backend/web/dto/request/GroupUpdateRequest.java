package dev.coderats.backend.web.dto.request;

import java.time.OffsetDateTime;
import java.util.List;

public record GroupUpdateRequest(
    String name,
    String description,
    String image,
    String repository,
    String method,
    Boolean status,
    OffsetDateTime end_date,
    List<String> remove_participants // IDs dos participantes a serem removidos
) {}
