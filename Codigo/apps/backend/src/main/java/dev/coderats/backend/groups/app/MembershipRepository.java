package dev.coderats.backend.groups.app;

import java.util.List;
import java.util.Optional;

import dev.coderats.backend.groups.domain.GroupId;
import dev.coderats.backend.groups.domain.Membership;
import dev.coderats.backend.users.domain.UserId;

// Esse arquivo define a interface para o repositório de membros de grupos.
// Ou seja, ele especifica os métodos que qualquer implementação concreta de repositório de membros deve fornecer.
public interface MembershipRepository {

    void save(Membership membership); // Criação
    Optional<Membership> findById(GroupId groupId, UserId userId); // Encontrar pelo id composto
    List<Membership> findByGroupId(GroupId groupId); // Listagem de participantes de um grupo
    List<Membership> findByUserId(UserId userId); // Listagem de grupos de um usuário
    void delete(Membership membership); // Remoção
    int countAdmins(GroupId groupId); // Contar administradores de um grupo (auxiliar para regras de negócio)
}