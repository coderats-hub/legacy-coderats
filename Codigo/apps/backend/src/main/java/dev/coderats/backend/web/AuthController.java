package dev.coderats.backend.web;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.springframework.http.HttpStatus; 
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController; 
import org.springframework.web.servlet.view.RedirectView;

import dev.coderats.backend.auth.EphemeralStore;
import dev.coderats.backend.github.GitHubOAuthService;
import dev.coderats.backend.repository.UserRepository;
import dev.coderats.backend.service.AuthService;
import dev.coderats.backend.web.dto.AuthResponse;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;
    private final GitHubOAuthService oauth;
    private final EphemeralStore store;
    private final UserRepository users;

    public AuthController(AuthService authService, GitHubOAuthService oauth, EphemeralStore store, UserRepository users) {
        this.authService = authService;
        this.oauth = oauth;
        this.store = store;
        this.users = users;
    }

    public static class AuthFlowException extends RuntimeException {
        public AuthFlowException(String message) {
            super(message);
        }
        public AuthFlowException(String message, Throwable cause) {
            super(message, cause);
        }
    }

    @ExceptionHandler(AuthFlowException.class)
    public ResponseEntity<String> handleAuthFlowException(AuthFlowException ex) {
        log.warn("Falha no fluxo de autenticação: {}", ex.getMessage());
        
        String htmlBody = """
          <html><body style="font-family: 'Segoe UI', sans-serif; background-color: #282c34; color: #e0e0e0; display: flex; justify-content: center; align-items: center; height: 100vh; text-align: center;">
            <div>
              <h3>Erro no Login</h3>
              <p style="color: #ff8b8b;">Ocorreu um erro: %s</p>
              <p>Por favor, feche esta janela e tente fazer o login novamente.</p>
            </div>
          </body></html>
        """.formatted(ex.getMessage());
        
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(htmlBody);
    }


    @GetMapping("/github/login")
    public RedirectView login(@RequestParam(defaultValue = "web") String client,
            @RequestParam(required = false) String cont) {
        String meta = client + "|" + (cont != null ? cont : "");
        String state = store.saveState(meta, 300);
        String url = oauth.buildAuthorizeUrl(state);
        return new RedirectView(url);
    }

    @GetMapping("/github/callback")
    public RedirectView callback(@RequestParam String code, @RequestParam String state) {
        log.info("🔑 Recebendo callback OAuth do GitHub com code={}", code);

        String meta = store.consumeState(state);
        if (!StringUtils.hasText(meta)) {
            throw new AuthFlowException("State inválido ou expirado.");
        }

        AuthResponse auth;
        try {
            auth = authService.githubLogin(code);

        } catch (Exception ex) {
            log.error("Falha ao executar authService.githubLogin", ex);
            throw new AuthFlowException("Não foi possível validar o login com o GitHub.", ex);
        }
        
        String payload = auth.token(); 
        String loginCode = store.saveLoginCode(payload, 120);

        String url = "/auth/finish?login_code=" + URLEncoder.encode(loginCode, StandardCharsets.UTF_8);
        return new RedirectView(url);
    }

    public record ExchangeRequest(String login_code) {}
    public record ExchangeResponse(String token) {}

    @PostMapping("/exchange")
    public ResponseEntity<ExchangeResponse> exchange(@RequestBody ExchangeRequest req) {
        String jwt = store.consumeLoginCode(req.login_code());
        if (!StringUtils.hasText(jwt)) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(new ExchangeResponse(jwt));
    }

    @GetMapping("/finish")
    public String finish(@RequestParam("login_code") String code) {
        return """
        <!DOCTYPE html>
        <html lang="pt-BR">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Login Concluído</title>
            <style>
                body {
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    background-color: #282c34; /* Fundo cinza escuro */
                    color: #e0e0e0; /* Texto claro */
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                    min-height: 100vh;
                    margin: 0;
                    text-align: center;
                    padding: 20px;
                    box-sizing: border-box;
                }
                .container {
                    max-width: 600px;
                    padding: 30px;
                    background-color: #3a3f47; /* Um tom um pouco mais claro para o "card" */
                    border-radius: 8px;
                    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
                }
                h3 {
                    font-size: 2.5em; /* Título maior */
                    color: #ffffff; /* Branco puro */
                    margin-bottom: 10px;
                    letter-spacing: 0.5px;
                }
                p {
                    font-size: 1.1em; /* Parágrafo menor */
                    color: #b0b0b0; /* Cinza claro */
                    margin-bottom: 25px;
                    line-height: 1.5;
                }
                .code-display {
                    background-color: #1a1e24; /* Fundo ainda mais escuro para o código */
                    color: #25A18E; /* Texto verde para o código, tipo console */
                    padding: 15px 20px;
                    border-radius: 6px;
                    font-family: 'Consolas', 'Courier New', monospace;
                    font-size: 1.2em;
                    word-break: break-all; /* Garante que o código quebra linha */
                    overflow-wrap: break-word; /* Para navegadores mais novos */
                    margin-bottom: 20px;
                    border: 1px solid #4a4f57; /* Borda sutil */
                }
                .copy-button {
                    background-color: #4A0A77; /* Azul vibrante */
                    color: white;
                    border: none;
                    padding: 12px 25px;
                    border-radius: 5px;
                    font-size: 1em;
                    cursor: pointer;
                    transition: background-color 0.3s ease;
                }
                .copy-button:hover {
                    background-color: #D283FF; /* Azul mais escuro no hover */
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h3>Login Concluído</h3>
                <p>Copie o código abaixo e cole no seu aplicativo para finalizar a autenticação:</p>
                <div class="code-display" id="loginCode">%s</div>
                <button class="copy-button" onclick="copyCode()">Copiar Código</button>
            </div>

            <script>
                function copyCode() {
                    const codeElement = document.getElementById('loginCode');
                    const textToCopy = codeElement.innerText;
                    
                    navigator.clipboard.writeText(textToCopy).then(() => {
                        alert('Código copiado para a área de transferência!');
                        // Opcional: Mudar o texto do botão para "Copiado!" temporariamente
                        // const button = document.querySelector('.copy-button');
                        // button.innerText = 'Copiado!';
                        // setTimeout(() => button.innerText = 'Copiar Código', 2000);
                    }).catch(err => {
                        console.error('Falha ao copiar o código: ', err);
                        alert('Não foi possível copiar o código automaticamente. Por favor, copie manualmente.');
                    });
                }
            </script>
        </body>
        </html>
        """.formatted(code);
    }
}
