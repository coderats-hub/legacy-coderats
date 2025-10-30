package dev.coderats.backend.features.group;

import dev.coderats.backend.features.group.Group;
import dev.coderats.backend.features.group.GroupRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GroupService {
    private final GroupRepository groupRepository;

    public GroupService(GroupRepository groupRepository) {
        this.groupRepository = groupRepository;
    }

    public List<Group> getGroupsForUser(String userId) {
        return groupRepository.findGroupsByUserId(userId);
    }
}
