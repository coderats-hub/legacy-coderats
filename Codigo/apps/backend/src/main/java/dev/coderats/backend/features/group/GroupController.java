package dev.coderats.backend.features.group;

import dev.coderats.backend.features.group.Group;
import dev.coderats.backend.features.group.GroupService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users/me/groups")
public class GroupController {

    private final GroupService groupService;

    public GroupController(GroupService groupService) {
        this.groupService = groupService;
    }

    @GetMapping
    public List<Group> listMyGroups(@RequestHeader("Authorization") String token) {
        String userId = extractUserIdFromToken(token); // implementar essa parte
        return groupService.getGroupsForUser(userId);
    }

    private String extractUserIdFromToken(String token) {
        // Aqui você decodifica o JWT e extrai o userId
        return "a1b2c3d4-e5f6-7890-1234-567890abcdef"; // Exemplo fixo
    }
}
