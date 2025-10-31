package dev.coderats.backend.features.test;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/test")
public class TestController {

    @GetMapping("/ping")
    public Map<String, Object> ping() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Backend funcionando!");
        response.put("timestamp", OffsetDateTime.now());
        response.put("status", "OK");
        return response;
    }

    @PostMapping("/echo")
    public Map<String, Object> echo() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "POST funcionando!");
        response.put("timestamp", OffsetDateTime.now());
        response.put("received", "Dados recebidos com sucesso");
        return response;
    }
}
