package dev.coderats.backend.checkins.domain;
import dev.coderats.backend.shared.domain.Identifier;

public final class CommitId extends Identifier {
    private CommitId(String value) { super(value); }
    public static CommitId newId() { return new CommitId(Identifier.newUUID()); }
    public static CommitId of(String value) { return new CommitId(value); }
}