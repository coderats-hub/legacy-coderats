package dev.coderats.backend.groups.domain;

public enum GroupStatus {
    ACTIVE,
    INACTIVE;

    public static GroupStatus fromString(String value) {
        return switch (value.toUpperCase()) {
            case "ACTIVE" -> ACTIVE;
            case "INACTIVE" -> INACTIVE;
            default -> throw new IllegalArgumentException("Unknown status: " + value);
        };
    }
}