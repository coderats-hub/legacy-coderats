package dev.coderats.backend.service;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.domain.User;
import dev.coderats.backend.infra.http.github.GitHubOAuthClient;
import dev.coderats.backend.infra.repository.UserRepository;
import dev.coderats.backend.infra.security.JwtService;
import dev.coderats.backend.web.dto.response.AuthResponse;
import dev.coderats.backend.web.dto.response.PrivateUserResponse;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class AuthService {
  private final GitHubOAuthClient gh;
  private final UserRepository users;
  private final JwtService jwt;

  public AuthService(GitHubOAuthClient gh, UserRepository users, JwtService jwt) {
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

    User user = users.findByGithubId(ghUser.id()).orElseGet(User::new);

    user.setGithubId(ghUser.id());
    user.setGithubUser(login);
    user.setName(name);
    user.setEmail(ghUser.email());
    user.setImage(ghUser.avatar_url());

    if (user.getCreatedAt() == null) user.setCreatedAt(now);
    user.setUpdatedAt(now);

    user = users.save(user);

    String jwtToken = jwt.generate(user.getId(), user.getGithubUser());
    var dto = new PrivateUserResponse(
        user.getId(), user.getName(), user.getEmail(), user.getImage(),
        user.getGithubUser(), user.getGithubId()
    );

    return new AuthResponse(dto, jwtToken);
  }
}
