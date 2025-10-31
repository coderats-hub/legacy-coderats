package dev.coderats.backend.security;

import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import dev.coderats.backend.config.JwtService;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    AuthenticationEntryPoint restEntryPoint() {
        return (req, res, ex) -> {
            res.setStatus(401);
            res.setContentType("application/json");
            res.getWriter().write("""
        {"statusCode":401,"message":"Token de autenticação não fornecido ou inválido."}
      """);
        };
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        configuration.setAllowedOrigins(List.of("http://localhost:8082"));
        
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD"));
        
        configuration.setAllowedHeaders(List.of("Authorization", "Content-Type", "X-Requested-With"));
        
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        
        return source;
    }

    @Bean
    public JwtAuthFilter jwtAuthFilter(JwtService jwtService) {
        return new JwtAuthFilter(jwtService);
    }

    @Bean
    SecurityFilterChain filterChain(HttpSecurity http, JwtAuthFilter jwt, AuthenticationEntryPoint ep) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                
                .cors(Customizer.withDefaults()) 
                
                .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .exceptionHandling(eh -> eh.authenticationEntryPoint(ep))
                .authorizeHttpRequests(reg -> reg
                .requestMatchers(HttpMethod.GET, "/").permitAll()
                .requestMatchers("/auth/**").permitAll() // <— garante GET e POST
                .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                .anyRequest().authenticated()
                )
                .formLogin(fl -> fl.disable())
                .httpBasic(hb -> hb.disable())
                .logout(lo -> lo.disable());

        http.addFilterBefore(jwt, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}