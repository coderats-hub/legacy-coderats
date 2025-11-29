package dev.coderats.backend.service;

import java.io.IOException;
import java.io.InputStream;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.ObjectCannedACL;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;

@Service
public class ImageStorageService {

    private final S3Client s3Client;
    private final String bucketName;
    private final String basePath;
    private final String publicBaseUrl;

    public ImageStorageService(
            S3Client s3Client,
            @Value("${aws.s3.bucket-name:coderats-files-starter}") String bucketName,
            @Value("${aws.s3.base-path:public/images/}") String basePath,
            @Value("${aws.s3.public-base-url:https://coderats-files-starter.s3.us-east-2.amazonaws.com}") String publicBaseUrl) {
        this.s3Client = s3Client;
        this.bucketName = bucketName;
        this.basePath = normalizeBasePath(basePath);
        this.publicBaseUrl = trimTrailingSlash(publicBaseUrl);
    }

    public UploadedImage upload(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("Arquivo de imagem vazio.");
        }

        String key = buildObjectKey(file.getOriginalFilename());
        String contentType = file.getContentType() != null ? file.getContentType() : "application/octet-stream";

        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(bucketName)
                .key(key)
                .contentType(contentType)
                .acl(ObjectCannedACL.PUBLIC_READ)
                .build();

        try (InputStream inputStream = file.getInputStream()) {
            s3Client.putObject(request, RequestBody.fromInputStream(inputStream, file.getSize()));
        } catch (IOException e) {
            throw new RuntimeException("Falha ao ler o arquivo para upload.", e);
        } catch (S3Exception e) {
            throw new RuntimeException("Falha ao enviar o arquivo para o S3: " + e.awsErrorDetails().errorMessage(), e);
        }

        String url = buildPublicUrl(key);
        return new UploadedImage(key, url);
    }

    private String buildObjectKey(String originalFilename) {
        String extension = extractExtension(originalFilename);
        return basePath + UUID.randomUUID() + extension;
    }

    private String extractExtension(String originalFilename) {
        if (originalFilename == null) {
            return "";
        }
        int idx = originalFilename.lastIndexOf('.');
        if (idx == -1 || idx == originalFilename.length() - 1) {
            return "";
        }
        String ext = originalFilename.substring(idx).toLowerCase();
        return ext.replaceAll("[^\\.a-z0-9]", "");
    }

    private String buildPublicUrl(String key) {
        String normalizedKey = key.startsWith("/") ? key.substring(1) : key;
        return publicBaseUrl + "/" + normalizedKey;
    }

    private String normalizeBasePath(String value) {
        String normalized = value != null ? value.trim() : "";
        if (normalized.startsWith("/")) {
            normalized = normalized.substring(1);
        }
        if (!normalized.endsWith("/")) {
            normalized = normalized + "/";
        }
        return normalized;
    }

    private String trimTrailingSlash(String value) {
        if (value == null) {
            return "";
        }
        if (value.endsWith("/")) {
            return value.substring(0, value.length() - 1);
        }
        return value;
    }

    public record UploadedImage(String key, String url) { }
}
