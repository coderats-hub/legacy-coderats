package dev.coderats.backend.groups.domain;

public enum GroupRole {
    ADMIN,
    MEMBER;

    public static GroupRole fromString(String value) {
        return switch (value.toUpperCase()) {
            case "ADMIN" -> ADMIN;
            case "MEMBER" -> MEMBER;
            default -> throw new IllegalArgumentException("Unknown role: " + value);
        };
    }
}
