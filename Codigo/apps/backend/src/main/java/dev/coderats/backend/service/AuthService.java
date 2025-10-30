package dev.coderats.backend.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.config.JwtService;
import dev.coderats.backend.domain.User;
import dev.coderats.backend.github.GitHubOAuthService;
import dev.coderats.backend.repository.UserRepository;
import dev.coderats.backend.web.dto.AuthResponse;
import dev.coderats.backend.web.dto.PrivateUserResponse;

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
    String token = gh.exchangeCodeForToken(code);
    var ghUser = gh.getUser(token);

    var user = users.findByGithubId(ghUser.id())
      .orElseGet(() -> users.save(new User()));
    // preencher/atualizar campos
    user.setGithubId(ghUser.id());
    user.setGithubUser(ghUser.login());
    user.setName(ghUser.name() != null ? ghUser.name() : ghUser.login());
    user.setImage(ghUser.avatar_url());
    user.setEmail(ghUser.email());
    users.save(user);

    String jwtToken = jwt.generate(user.getId(), user.getGithubUser());
    var dto = new PrivateUserResponse(user.getId(), user.getName(), user.getEmail(), user.getImage(), user.getGithubUser(), user.getGithubId());
    return new AuthResponse(dto, jwtToken);
  }
}
