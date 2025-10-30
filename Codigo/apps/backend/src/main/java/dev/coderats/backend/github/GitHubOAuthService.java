package dev.coderats.backend.github;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class GitHubOAuthService {

  @Value("${github.oauth.client-id}")
  private String clientId;

  @Value("${github.oauth.client-secret}")
  private String clientSecret;

  @Value("${github.oauth.redirect-uri}")
  private String redirectUri;

  private final RestTemplate restTemplate = new RestTemplate();

  public record TokenResponse(String access_token, String scope, String token_type) {}
  public record GitHubUser(Long id, String login, String name, String avatar_url, String email) {}

  public String exchangeCodeForToken(String code) {
    String url = "https://github.com/login/oauth/access_token";

    Map<String, String> body = new HashMap<>();
    body.put("client_id", clientId);
    body.put("client_secret", clientSecret);
    body.put("code", code);
    body.put("redirect_uri", redirectUri);

    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_JSON);
    headers.setAccept(java.util.List.of(MediaType.APPLICATION_JSON));

    HttpEntity<Map<String, String>> entity = new HttpEntity<>(body, headers);

    ResponseEntity<TokenResponse> response = restTemplate.exchange(
        url, HttpMethod.POST, entity, TokenResponse.class);

    if (response.getBody() == null || response.getBody().access_token() == null) {
      throw new RuntimeException("Falha ao obter access_token do GitHub");
    }

    return response.getBody().access_token();
  }

  public GitHubUser getUser(String accessToken) {
    String url = "https://api.github.com/user";

    HttpHeaders headers = new HttpHeaders();
    headers.setBearerAuth(accessToken);
    headers.setAccept(java.util.List.of(MediaType.APPLICATION_JSON));

    HttpEntity<Void> entity = new HttpEntity<>(headers);

    ResponseEntity<GitHubUser> response = restTemplate.exchange(
        url, HttpMethod.GET, entity, GitHubUser.class);

    if (response.getBody() == null) {
      throw new RuntimeException("Falha ao buscar dados do usuário no GitHub");
    }

    return response.getBody();
  }
}
