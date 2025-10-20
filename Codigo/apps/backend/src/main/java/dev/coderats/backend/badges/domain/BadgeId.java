package dev.coderats.backend.badges.domain;

import dev.coderats.backend.shared.domain.Identifier;

public final class BadgeId extends Identifier {
    private BadgeId(String value) { super(value); }
    public static BadgeId newId() { return new BadgeId(Identifier.newUUID()); }
    public static BadgeId of(String value) { return new BadgeId(value); }
}