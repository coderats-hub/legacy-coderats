package dev.coderats.backend.checkins.api.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonProperty;

public record CheckinResponseDTO(
    UUID id,
    String title,
    String description,
    String image,
    
    @JsonProperty("summary_ai") 
    String summaryAi,
    
    int points,
    Instant createdAt,
    UserSummaryDTO author,
    List<CommitDTO> commits,
    
    @JsonProperty("likes_count")
    int likesCount,
    
    @JsonProperty("liked_by_me")
    boolean likedByMe,
    
    List<CommentResponseDTO> comments
) {}