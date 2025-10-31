package dev.coderats.backend.github;

import com.fasterxml.jackson.annotation.JsonProperty;

public record GithubUserProfile(
    Long id,
    String login,
    String name,
    @JsonProperty("avatar_url") String avatarUrl
) {
}