package dev.coderats.backend.infra.http.github;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

@Service
public class GitHubOAuthClient {

  @Value("${github.oauth.client-id}")
  private String clientId;

  @Value("${github.oauth.client-secret}")
  private String clientSecret;

  @Value("${github.oauth.redirect-uri}")
  private String redirectUri;

  private final RestClient http = RestClient.create();

  public record TokenResponse(String access_token, String scope, String token_type, String error, String error_description) {}
  public record GitHubUser(Long id, String login, String name, String avatar_url, String email) {}
  public record GitHubEmail(String email, boolean primary, boolean verified, String visibility) {}

  public String buildAuthorizeUrl(String state) {
    return "https://github.com/login/oauth/authorize"
      + "?client_id=" + clientId
      + "&redirect_uri=" + redirectUri
      + "&scope=read:user%20user:email"
      + "&state=" + state;
  }

  public String exchangeCodeForToken(String code) {
    TokenResponse res = http.post()
      .uri("https://github.com/login/oauth/access_token")
      .contentType(MediaType.APPLICATION_JSON)
      .accept(MediaType.APPLICATION_JSON)
      .body(java.util.Map.of(
        "client_id", clientId,
        "client_secret", clientSecret,
        "code", code,
        "redirect_uri", redirectUri
      ))
      .retrieve()
      .body(TokenResponse.class);

    if (res == null || res.access_token() == null) {
      String msg = (res != null && res.error() != null)
        ? res.error() + " - " + res.error_description()
        : "sem corpo";
      throw new RuntimeException("Falha ao obter access_token do GitHub: " + msg);
    }
    return res.access_token();
  }

  public GitHubUser getUser(String accessToken) {
    GitHubUser u = http.get()
      .uri("https://api.github.com/user")
      .header("Authorization", "Bearer " + accessToken)
      .accept(MediaType.APPLICATION_JSON)
      .retrieve()
      .body(GitHubUser.class);
    if (u == null) throw new RuntimeException("Falha ao buscar dados do usuário no GitHub");
    return u;
  }

  public String getPrimaryEmail(String accessToken) {
    GitHubEmail[] emails = http.get()
      .uri("https://api.github.com/user/emails")
      .header("Authorization", "Bearer " + accessToken)
      .accept(MediaType.APPLICATION_JSON)
      .retrieve()
      .body(GitHubEmail[].class);
    if (emails == null || emails.length == 0) return null;
    for (GitHubEmail e : emails) if (e.primary) return e.email;
    return emails[0].email;
  }
}
