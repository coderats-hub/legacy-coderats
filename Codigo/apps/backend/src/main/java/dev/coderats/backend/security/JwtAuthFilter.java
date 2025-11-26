package dev.coderats.backend.security;

import java.io.IOException;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.filter.OncePerRequestFilter;

import dev.coderats.backend.infra.security.JwtService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class JwtAuthFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(JwtAuthFilter.class);

    private final JwtService jwtService;
    private final AntPathMatcher matcher = new AntPathMatcher();

    // rotas SEM autenticação
    private final List<String> publicPatterns = List.of(
            "/",
            "/auth/**",
            "/v3/api-docs/**",
            "/swagger-ui/**",
            "/swagger-ui.html"
    );

    public JwtAuthFilter(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getServletPath(); // mais confiável que getRequestURI()
        for (String p : publicPatterns) {
            if (matcher.match(p, path)) {
                log.debug("[JWT] SKIP filter for path={}", path);
                return true; // não filtra /auth/**
            }
        }
        return "OPTIONS".equalsIgnoreCase(request.getMethod());
    }

    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
            throws ServletException, IOException {

        String path = req.getServletPath();
        String auth = req.getHeader(HttpHeaders.AUTHORIZATION);

        System.out.println("========================================");
        System.out.println("[DEBUG] Rota acessada: " + path);
        System.out.println("[DEBUG] Header Authorization recebido: " + auth);

        if (auth == null || !auth.startsWith("Bearer ")) {
            log.debug("[JWT] No bearer token on path={}, continuing without auth", path);
            chain.doFilter(req, res);
            return;
        }

        String token = auth.substring(7);
        try {
            var jws = jwtService.parse(token); // NÃO lance AuthenticationException aqui
            System.out.println("Token recebido: " + jws);
            var userId = jws.getPayload().getSubject();

            var authentication = new UsernamePasswordAuthenticationToken(userId, null, List.of());
            SecurityContextHolder.getContext().setAuthentication(authentication);
            log.debug("[JWT] Authenticated subject={} for path={}", userId, path);
        } catch (Exception e) {
            // token inválido -> não autentica, mas NÃO responde 401 aqui
            log.debug("[JWT] Invalid token on path={}, ignoring. Error={}", path, e.getMessage());
            SecurityContextHolder.clearContext();
        }

        chain.doFilter(req, res);
    }
}
