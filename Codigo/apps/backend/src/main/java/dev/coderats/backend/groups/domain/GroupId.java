package dev.coderats.backend.groups.domain;

import dev.coderats.backend.shared.domain.Identifier;

public final class GroupId extends Identifier {

    // Esse construtor é privado para garantir que os IDs de grupo sejam criados apenas através dos métodos estáticos da classe.
    private GroupId(String value) {
        super(value);
    }

    public static GroupId newId() {
        return new GroupId(Identifier.newUUID());
    }

    public static GroupId of(String value) {
        return new GroupId(value);
    }
}
