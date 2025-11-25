package dev.coderats.backend.web.controller;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import dev.coderats.backend.domain.Group;
import dev.coderats.backend.service.GroupService;
import dev.coderats.backend.web.dto.request.GroupCreateRequest;
import dev.coderats.backend.web.dto.request.GroupUpdateRequest;
import dev.coderats.backend.web.dto.response.GroupResponse;
import dev.coderats.backend.web.dto.response.GroupWithDetailsResponse;

@RestController
public class GroupController {

    private final GroupService groupService;

    public GroupController(GroupService groupService) {
        this.groupService = groupService;
    }

    // GET /users/me/groups - Listar meus grupos
    @GetMapping("/users/me/groups")
    public ResponseEntity<List<GroupResponse>> listMyGroups() {
        UUID userId = getCurrentUserId();
        List<Group> groups = groupService.getGroupsForUser(userId);
        List<GroupResponse> response = groups.stream()
                .map(this::toResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(response);
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

    private GroupResponse toResponse(Group group) {
        return new GroupResponse(
                group.getId(),
                group.getName(),
                group.getDescription(),
                group.getImage(),
                group.getMethod(),
                group.getStartDate() != null ? group.getStartDate().toInstant() : null,
                group.getEndDate() != null ? group.getEndDate().toInstant() : null
        );
    }
}
