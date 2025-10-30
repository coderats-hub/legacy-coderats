package dev.coderats.backend.web;

import dev.coderats.backend.service.AuthService;
import dev.coderats.backend.web.dto.AuthGithubCallbackRequest;
import dev.coderats.backend.web.dto.AuthResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {
  private final AuthService authService;
  public AuthController(AuthService authService){ this.authService = authService; }

  @PostMapping("/github/callback")
  public ResponseEntity<AuthResponse> callback(@RequestBody AuthGithubCallbackRequest body) {
    return ResponseEntity.ok(authService.githubLogin(body.code()));
  }
}
