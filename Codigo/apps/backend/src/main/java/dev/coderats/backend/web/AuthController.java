package dev.coderats.backend.web;

import dev.coderats.backend.service.AuthService;
import dev.coderats.backend.web.dto.AuthGithubCallbackRequest;
import dev.coderats.backend.web.dto.AuthResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/auth")
public class AuthController {
  private static final Logger log = LoggerFactory.getLogger(AuthController.class);
  private final AuthService authService;

  public AuthController(AuthService authService) {
    this.authService = authService;
  }

  @PostMapping("/github/callback")
  public ResponseEntity<AuthResponse> callback(@RequestBody(required = false) AuthGithubCallbackRequest body) {
    if (body == null || body.code() == null || body.code().isBlank()) {
      log.warn("⚠️ Requisição inválida: body ausente ou campo 'code' vazio");
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Campo 'code' é obrigatório.");
    }

    log.info("🔑 Recebendo callback OAuth do GitHub com code={}", body.code());

    try {
      var response = authService.githubLogin(body.code());
      log.info("✅ Login GitHub bem-sucedido para code={}", body.code());
      return ResponseEntity.ok(response);

    } catch (Exception e) {
      log.error("❌ Erro durante o login GitHub: {}", e.getMessage(), e);
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Falha ao processar autenticação do GitHub.");
    }
  }
}
