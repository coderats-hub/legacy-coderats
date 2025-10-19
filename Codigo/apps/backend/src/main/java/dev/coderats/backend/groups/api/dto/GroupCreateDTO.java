package dev.coderats.backend.groups.api.dto;

import java.net.URI;
import java.time.Instant;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record GroupCreateDTO(
    @NotNull(message = "O nome não pode ser nulo")
    @Size(min = 3, max = 255, message = "O nome deve ter entre 3 e 255 caracteres")
    String name,

    String description,
    String image,
    
    @Size(max = 50, message = "O código deve ter no máximo 50 caracteres")
    String code,

    String method,
    
    URI repository,

    @NotNull(message = "A data de início não pode ser nula")
    Instant startDate,

    @Future(message = "A data de término deve ser no futuro")
    Instant endDate
) {}