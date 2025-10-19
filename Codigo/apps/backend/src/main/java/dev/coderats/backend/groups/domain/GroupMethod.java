package dev.coderats.backend.groups.domain;

public enum GroupMethod {
    BIGGEST_PHOTO_STREAK,      // maior streak de fotos
    BIGGEST_COMMIT_STREAK,     // maior streak de commits
    MOST_COMMITS,              // maior número de commits
    MOST_LINES_OF_CODE;        // maior número de linhas de código

    public static GroupMethod fromString(String value) {
        return switch (value.toUpperCase()) {
            case "BIGGEST_PHOTO_STREAK" -> BIGGEST_PHOTO_STREAK;
            case "BIGGEST_COMMIT_STREAK" -> BIGGEST_COMMIT_STREAK;
            case "MOST_COMMITS" -> MOST_COMMITS;
            case "MOST_LINES_OF_CODE" -> MOST_LINES_OF_CODE;
            default -> throw new IllegalArgumentException("Unknown method: " + value);
        };
    }
}
