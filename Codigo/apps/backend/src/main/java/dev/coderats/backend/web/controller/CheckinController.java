package dev.coderats.backend.web.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import dev.coderats.backend.service.CheckinService;
import dev.coderats.backend.web.dto.request.CheckinCreateRequest;
import dev.coderats.backend.web.dto.request.CheckinPreviewRequest;
import dev.coderats.backend.web.dto.response.CheckinPreviewResponse;
import dev.coderats.backend.web.dto.response.CheckinResponse;

@RestController
public class CheckinController {

    private final CheckinService checkinService;

    public CheckinController(CheckinService checkinService) {
        this.checkinService = checkinService;
    }

    @GetMapping("/feed")
    public ResponseEntity<List<CheckinResponse>> getFeed(
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(defaultValue = "0") int offset) {
        UUID userId = getCurrentUserId();
        var data = checkinService.getFeed(userId, limit, offset);
        return ResponseEntity.ok(data);
    }

    @GetMapping("/groups/{groupId}/checkins")
    public ResponseEntity<List<CheckinResponse>> getByGroup(
            @PathVariable String groupId,
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(defaultValue = "0") int offset) {
        try {
            UUID gid = UUID.fromString(groupId);
            var data = checkinService.getGroupCheckins(gid, limit, offset);
            return ResponseEntity.ok(data);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/groups/{groupId}/checkins")
    public ResponseEntity<CheckinResponse> create(
            @PathVariable String groupId,
            @RequestBody CheckinCreateRequest request) {
        try {
            UUID gid = UUID.fromString(groupId);
            UUID userId = getCurrentUserId();
            var created = checkinService.createCheckin(userId, gid, request);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
    }

    @PostMapping("/checkins/preview")
    public ResponseEntity<CheckinPreviewResponse> preview(
            @RequestBody CheckinPreviewRequest request) {
        UUID userId = request.userId() != null ? request.userId() : getCurrentUserId();
        var result = checkinService.previewCheckin(userId, request.commits());
        return ResponseEntity.ok(new CheckinPreviewResponse(result.summary(), result.points()));
    }

    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication.getPrincipal();
        if (principal == null || "anonymousUser".equals(principal.toString())) {
            throw new RuntimeException("User not authenticated");
        }
        try {
            return UUID.fromString(principal.toString());
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid user ID format: " + principal);
        }
    }
}
