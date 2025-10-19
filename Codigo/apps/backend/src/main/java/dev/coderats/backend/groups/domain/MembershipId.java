package dev.coderats.backend.groups.domain;

import dev.coderats.backend.shared.domain.Identifier;

public final class MembershipId extends Identifier {

    private MembershipId(String value) {
        super(value);
    }

    public static MembershipId newId() {
        return new MembershipId(Identifier.newUUID());
    }

    public static MembershipId of(String value) {
        return new MembershipId(value);
    }
}