package dev.coderats.backend.github;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

@Service
public class GitHubOAuthService {

  @Value("${github.oauth.client-id}")
  private String clientId;

  @Value("${github.oauth.client-secret}")
  private String clientSecret;

  @Value("${github.oauth.redirect-uri}")
  private String redirectUri;

  private final RestClient rest = RestClient.builder()
      .baseUrl("https://github.com")
      .defaultHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE)
      .build();

  @JsonIgnoreProperties(ignoreUnknown = true)
  public record TokenResponse(
      @JsonProperty("access_token") String accessToken,
      String scope,
      @JsonProperty("token_type") String tokenType,
      String error,
      @JsonProperty("error_description") String errorDescription
  ) {}

  @JsonIgnoreProperties(ignoreUnknown = true)
  public record GitHubUser(
      Long id,
      String login,
      String name,
      @JsonProperty("avatar_url") String avatarUrl,
      String email
  ) {}

  public String exchangeCodeForToken(String code) {
    var body = """
      {
        "client_id":"%s",
        "client_secret":"%s",
        "code":"%s",
        "redirect_uri":"%s"
      }
      """.formatted(clientId, clientSecret, code, redirectUri);

    var resp = rest.post()
        .uri("/login/oauth/access_token")
        .contentType(MediaType.APPLICATION_JSON)
        .body(body)
        .retrieve()
        .toEntity(TokenResponse.class);

    var tr = resp.getBody();
    if (tr == null || tr.accessToken() == null) {
      var msg = (tr != null && tr.error() != null)
          ? "Falha ao obter access_token do GitHub: %s - %s".formatted(tr.error(), tr.errorDescription())
          : "Falha ao obter access_token do GitHub (resposta vazia)";
      throw new RuntimeException(msg);
    }
    return tr.accessToken();
  }

  public GitHubUser getUser(String accessToken) {
    var api = RestClient.builder()
        .baseUrl("https://api.github.com")
        .defaultHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE)
        .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken)
        .build();

    // GET /user
    var resp = api.get().uri("/user").retrieve().toEntity(GitHubUser.class);
    var gh = resp.getBody();
    if (gh == null) {
      throw new RuntimeException("Falha ao buscar dados do usuário no GitHub");
    }
    return gh;
  }
}
