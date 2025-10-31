package dev.coderats.backend.features.group;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
public class GroupController {

    private final GroupService groupService;

    public GroupController(GroupService groupService) {
        this.groupService = groupService;
    }

    // GET /users/me/groups - Listar meus grupos
    @GetMapping("/users/me/groups")
    public ResponseEntity<List<Group>> listMyGroups() {
        UUID userId = getCurrentUserId();
        List<Group> groups = groupService.getGroupsForUser(userId);
        return ResponseEntity.ok(groups);
    }

    // POST /groups - Criar novo grupo
    @PostMapping("/groups")
    public ResponseEntity<Group> createGroup(@RequestBody GroupCreateRequest request) {
        UUID creatorUserId = getCurrentUserId();
        Group createdGroup = groupService.createGroup(request, creatorUserId);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdGroup);
    }

    // GET /groups/{groupId} - Obter detalhes de um grupo
    @GetMapping("/groups/{groupId}")
    public ResponseEntity<GroupWithDetailsResponse> getGroupDetails(@PathVariable String groupId) {
        try {
            UUID groupUUID = UUID.fromString(groupId);
            GroupWithDetailsResponse groupDetails = groupService.getGroupWithDetails(groupUUID);
            
            if (groupDetails == null) {
                return ResponseEntity.notFound().build();
            }
            
            return ResponseEntity.ok(groupDetails);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // PATCH /groups/{groupId} - Atualizar grupo
    @PatchMapping("/groups/{groupId}")
    public ResponseEntity<Group> updateGroup(@PathVariable String groupId, @RequestBody GroupUpdateRequest request) {
        try {
            UUID groupUUID = UUID.fromString(groupId);
            UUID userId = getCurrentUserId();
            
            Group updatedGroup = groupService.updateGroup(groupUUID, request, userId);
            return ResponseEntity.ok(updatedGroup);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (RuntimeException e) {
            if (e.getMessage().contains("não encontrado")) {
                return ResponseEntity.notFound().build();
            } else if (e.getMessage().contains("administradores")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
            return ResponseEntity.badRequest().build();
        }
    }

    // DELETE /groups/{groupId} - Excluir grupo
    @DeleteMapping("/groups/{groupId}")
    public ResponseEntity<Void> deleteGroup(@PathVariable String groupId) {
        try {
            UUID groupUUID = UUID.fromString(groupId);
            UUID userId = getCurrentUserId();
            
            groupService.deleteGroup(groupUUID, userId);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (RuntimeException e) {
            if (e.getMessage().contains("não encontrado")) {
                return ResponseEntity.notFound().build();
            } else if (e.getMessage().contains("administradores")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
            return ResponseEntity.badRequest().build();
        }
    }

    // Método utilitário para extrair o userId do contexto de segurança
    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication.getPrincipal();
        
        // Check if user is authenticated (not anonymous)
        if (principal == null || "anonymousUser".equals(principal.toString())) {
            throw new RuntimeException("User not authenticated");
        }
        
        String userIdString = principal.toString();
        try {
            return UUID.fromString(userIdString);
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid user ID format: " + userIdString);
        }
    }
}
