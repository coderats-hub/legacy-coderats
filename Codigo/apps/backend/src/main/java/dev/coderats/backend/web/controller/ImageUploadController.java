package dev.coderats.backend.web.controller;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import dev.coderats.backend.service.ImageReferenceService;
import dev.coderats.backend.service.ImageReferenceService.TargetType;
import dev.coderats.backend.service.ImageStorageService;
import dev.coderats.backend.web.dto.response.ImageUploadResponse;

@RestController
@RequestMapping("/uploads")
public class ImageUploadController {

    private final ImageStorageService imageStorageService;
    private final ImageReferenceService imageReferenceService;

    public ImageUploadController(
            ImageStorageService imageStorageService,
            ImageReferenceService imageReferenceService) {
        this.imageStorageService = imageStorageService;
        this.imageReferenceService = imageReferenceService;
    }

    @PostMapping(value = "/images", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ImageUploadResponse> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "targetType", required = false) String targetType,
            @RequestParam(value = "entityId", required = false) String entityId) {
        try {
            UUID actorId = getCurrentUserId();

            if (StringUtils.hasText(targetType) ^ StringUtils.hasText(entityId)) {
                return ResponseEntity.badRequest().build();
            }

            UUID parsedEntityId = null;
            String normalizedTarget = null;
            if (StringUtils.hasText(targetType) && StringUtils.hasText(entityId)) {
                parsedEntityId = UUID.fromString(entityId);
                normalizedTarget = TargetType.from(targetType).name();
            }

            var uploaded = imageStorageService.upload(file);

            UUID persistedId = null;
            String persistedTarget = null;
            if (parsedEntityId != null && normalizedTarget != null) {
                var result = imageReferenceService.assign(normalizedTarget, parsedEntityId, uploaded.url(), actorId);
                persistedId = result.entityId();
                persistedTarget = result.targetType().name();
            }

            var response = new ImageUploadResponse(uploaded.url(), uploaded.key(), persistedTarget, persistedId);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (IllegalStateException e) {
            HttpStatus status = e.getMessage() != null && e.getMessage().contains("autenticado")
                    ? HttpStatus.UNAUTHORIZED
                    : HttpStatus.FORBIDDEN;
            return ResponseEntity.status(status).build();
        }
    }

    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication != null ? authentication.getPrincipal() : null;

        if (principal == null || "anonymousUser".equals(principal.toString())) {
            throw new IllegalStateException("Usuário não autenticado");
        }

        try {
            return UUID.fromString(principal.toString());
        } catch (IllegalArgumentException e) {
            throw new IllegalStateException("Identificador de usuário inválido");
        }
    }
}
