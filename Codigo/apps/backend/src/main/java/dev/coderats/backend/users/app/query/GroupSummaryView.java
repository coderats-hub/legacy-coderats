package dev.coderats.backend.users.app.query;

public record GroupSummaryView(
    String id, 
    String name, 
    boolean status, 
    String image
) {
}