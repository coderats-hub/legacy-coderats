package dev.coderats.backend.groups.app;

import java.util.Optional;

import dev.coderats.backend.groups.domain.Group;
import dev.coderats.backend.groups.domain.GroupId;

// Esse arquivo define a interface para o repositório de grupos.
// Ou seja, ele especifica os métodos que qualquer implementação concreta de repositório de grupos deve fornecer.
public interface GroupRepository {

    void save(Group group); // Criação
    Optional<Group> findById(GroupId groupId); // Encontrar pelo id
    boolean existsByCode(String code); // Verificar existência pelo código
    Optional<Group> findByCode(String code); // Encontrar pelo código
}