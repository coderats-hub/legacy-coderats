package dev.coderats.backend.users.app.query;

public record BadgeView(
    String id, 
    String name, 
    String image, 
    String description, 
    int points
) {
}