package dev.coderats.backend.features.group;

import java.util.List;

public interface GroupRepository {
    List<Group> findGroupsByUserId(String userId);
}

