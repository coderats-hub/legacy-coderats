package dev.coderats.backend.service;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.config.JwtService;
import dev.coderats.backend.domain.User;
import dev.coderats.backend.github.GitHubOAuthService;
import dev.coderats.backend.repository.UserRepository;
import dev.coderats.backend.web.dto.AuthResponse;
import dev.coderats.backend.web.dto.PrivateUserResponse;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class AuthService {
  private final GitHubOAuthService gh;
  private final UserRepository users;
  private final JwtService jwt;

  public AuthService(GitHubOAuthService gh, UserRepository users, JwtService jwt) {
    this.gh = gh; this.users = users; this.jwt = jwt;
  }

  @Transactional
  public AuthResponse githubLogin(String code) {
    log.info("🔑 Recebendo callback OAuth do GitHub com code={}", code);

    String accessToken = gh.exchangeCodeForToken(code);
    var ghUser = gh.getUser(accessToken);

    String login = (ghUser.login() != null && !ghUser.login().isBlank()) ? ghUser.login() : "gh-" + ghUser.id();
    String name  = (ghUser.name()  != null && !ghUser.name().isBlank())  ? ghUser.name()  : login;
    var now = OffsetDateTime.now(ZoneOffset.UTC);

    // Busca por githubId; se não existe, cria NOVO User SEM id (Hibernate gera no INSERT)
    User user = users.findByGithubId(ghUser.id()).orElseGet(User::new);

    // Preenche/atualiza sempre no MESMO objeto
    user.setGithubId(ghUser.id());
    user.setGithubUser(login);
    user.setName(name);
    user.setEmail(ghUser.email());
    user.setImage(ghUser.avatarUrl());

    if (user.getCreatedAt() == null) user.setCreatedAt(now);
    user.setUpdatedAt(now);

    // Um único save (INSERT se novo; UPDATE se existente)
    user = users.save(user);

    String jwtToken = jwt.generate(user.getId(), user.getGithubUser());
    var dto = new PrivateUserResponse(
        user.getId(), user.getName(), user.getEmail(), user.getImage(),
        user.getGithubUser(), user.getGithubId()
    );

    return new AuthResponse(dto, jwtToken);
  }
}
