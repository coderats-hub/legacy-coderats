package dev.coderats.backend.checkins.domain;
import dev.coderats.backend.shared.domain.Identifier;

public final class CommentId extends Identifier {
    private CommentId(String value) { super(value); }
    public static CommentId newId() { return new CommentId(Identifier.newUUID()); }
    public static CommentId of(String value) { return new CommentId(value); }
}