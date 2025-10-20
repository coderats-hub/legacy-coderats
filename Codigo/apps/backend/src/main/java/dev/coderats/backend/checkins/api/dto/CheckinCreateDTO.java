package dev.coderats.backend.checkins.api.dto;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.validation.constraints.NotBlank;

public record CheckinCreateDTO(
    @NotBlank(message = "O título é obrigatório")
    String title,
    String description,
    String image, // URI
    @JsonProperty("summary_ai")
    String summaryAi,
    List<CommitCreateDTO> commits
) {}