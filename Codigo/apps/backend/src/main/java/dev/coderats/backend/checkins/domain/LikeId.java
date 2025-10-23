package dev.coderats.backend.checkins.domain;
import dev.coderats.backend.shared.domain.Identifier;

public final class LikeId extends Identifier {
    private LikeId(String value) { super(value); }
    public static LikeId newId() { return new LikeId(Identifier.newUUID()); }
    public static LikeId of(String value) { return new LikeId(value); }
}