package dev.coderats.backend.users.domain;

import dev.coderats.backend.shared.domain.Identifier;

// Mesma coisa que groupId, para manter o padrão de código
public final class UserId extends Identifier {

    private UserId(String value) {
        super(value);
    }

    public static UserId newId() {
        return new UserId(Identifier.newUUID());
    }

    public static UserId of(String value) {
        return new UserId(value);
    }
}