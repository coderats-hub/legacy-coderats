package dev.coderats.backend.users.domain;

import dev.coderats.backend.shared.domain.Identifier;

public final class UserId extends Identifier {

    // Esse construtor é privado para garantir que os IDs de usuário sejam criados apenas através dos métodos estáticos da classe.
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
