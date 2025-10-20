package dev.coderats.backend.checkins.domain;
import dev.coderats.backend.shared.domain.Identifier;

public final class CheckinId extends Identifier {
    private CheckinId(String value) { super(value); }
    public static CheckinId newId() { return new CheckinId(Identifier.newUUID()); }
    public static CheckinId of(String value) { return new CheckinId(value); }
}