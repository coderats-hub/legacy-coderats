package dev.coderats.backend.web.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import dev.coderats.backend.service.GitHubCommitService;
import dev.coderats.backend.web.dto.response.GitHubCommitResponse;

@RestController
@RequestMapping("/integrations/github")
public class GitHubIntegrationController {

    private final GitHubCommitService gitHubCommitService;

    public GitHubIntegrationController(GitHubCommitService gitHubCommitService) {
        this.gitHubCommitService = gitHubCommitService;
    }

    @GetMapping("/commits")
    public ResponseEntity<List<GitHubCommitResponse>> listCommits(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "5") int size) {
        UUID userId = getCurrentUserId();
        var commits = gitHubCommitService.fetchRecentCommits(userId, page, size);
        return ResponseEntity.ok(commits);
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
