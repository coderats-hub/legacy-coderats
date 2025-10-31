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

@Slf4j
@Service
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
    String email = ghUser.email();
    if (email == null) email = gh.getPrimaryEmail(accessToken);

    var user = users.findByGithubId(ghUser.id())
      .orElseGet(() -> users.save(new User()));
    boolean isNew = (user.getId() == null);

    user.setGithubId(ghUser.id());
    user.setGithubUser(ghUser.login());
    user.setName(ghUser.name() != null ? ghUser.name() : ghUser.login());
    user.setImage(ghUser.avatar_url());
    user.setEmail(email);
    var now = OffsetDateTime.now(ZoneOffset.UTC);
    if (user.getCreatedAt() == null) user.setCreatedAt(now);
    user.setUpdatedAt(now);

    user = users.saveAndFlush(user);

    if (isNew) log.info("🆕 Novo usuário GitHub detectado: {}", user.getGithubUser());

    String jwtToken = jwt.generate(user.getId(), user.getGithubUser());
    var dto = new PrivateUserResponse(
      user.getId(), user.getName(), user.getEmail(),
      user.getImage(), user.getGithubUser(), user.getGithubId()
    );
    return new AuthResponse(dto, jwtToken);
  }

  @Transactional(readOnly = true)
  public AuthResponse buildAuthResponse(User user) {
    String jwtToken = jwt.generate(user.getId(), user.getGithubUser());
    var dto = new PrivateUserResponse(
      user.getId(), user.getName(), user.getEmail(),
      user.getImage(), user.getGithubUser(), user.getGithubId()
    );
    return new AuthResponse(dto, jwtToken);
  }
}
