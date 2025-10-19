// src/main/java/dev/coderats/backend/groups/app/ports/GroupRepository.java
package dev.coderats.backend.groups.app.ports;

import java.util.Optional;

import dev.coderats.backend.groups.domain.Group;
import dev.coderats.backend.groups.domain.GroupId;

public interface GroupRepository {
    void save(Group group);
    void update(Group group);
    void delete(GroupId id);

    Optional<Group> findById(GroupId id);
    Optional<Group> findByCode(String code);
    boolean existsByCode(String code);
}
