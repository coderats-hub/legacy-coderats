package dev.coderats.backend.service;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.azure.identity.DefaultAzureCredentialBuilder;
import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.BlobServiceClientBuilder;
import com.azure.storage.blob.specialized.BlockBlobClient;
import com.azure.storage.blob.models.BlobHttpHeaders;

@Service
@ConditionalOnProperty(name = "storage.provider", havingValue = "azure-blob", matchIfMissing = true)
public class AzureBlobImageStorageService implements ImageStorageService {

    private final BlobContainerClient containerClient;
    private final String basePath;
    private final String publicBaseUrl;

    public AzureBlobImageStorageService(
            @Value("${storage.azure.blob.connection-string:}") String connectionString,
            @Value("${storage.azure.blob.account-name:}") String accountName,
            @Value("${storage.azure.blob.container:coderats-images}") String containerName,
            @Value("${storage.azure.blob.base-path:public/images/}") String basePath,
            @Value("${storage.azure.blob.public-base-url:}") String publicBaseUrl) {

        BlobServiceClient serviceClient;
        if (connectionString != null && !connectionString.isBlank()) {
            serviceClient = new BlobServiceClientBuilder().connectionString(connectionString).buildClient();
        } else {
            if (accountName == null || accountName.isBlank()) {
                throw new IllegalArgumentException("AZURE_STORAGE_ACCOUNT is required when connection string is not provided");
            }
            String endpoint = "https://" + accountName + ".blob.core.windows.net";
            serviceClient = new BlobServiceClientBuilder().endpoint(endpoint)
                    .credential(new DefaultAzureCredentialBuilder().build())
                    .buildClient();
        }

        this.containerClient = serviceClient.getBlobContainerClient(containerName);
        this.basePath = normalizeBasePath(basePath);
        this.publicBaseUrl = trimTrailingSlash(publicBaseUrl);
    }

    @Override
    public UploadedImage upload(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("Arquivo de imagem vazio.");
        }

        String contentType = file.getContentType() != null ? file.getContentType() : "application/octet-stream";
        if (!contentType.startsWith("image/")) {
            throw new IllegalArgumentException("Arquivo não é uma imagem.");
        }

        String extension = extractExtension(file.getOriginalFilename());
        String blobName = basePath + UUID.randomUUID() + extension;

        // Lazy container check avoids crashing the whole app at startup when Blob auth is temporarily unavailable.
        if (!containerClient.exists()) {
            containerClient.create();
        }

        BlockBlobClient blobClient = containerClient.getBlobClient(blobName).getBlockBlobClient();
        try {
            byte[] bytes = file.getBytes();
            blobClient.upload(new ByteArrayInputStream(bytes), bytes.length, true);
            BlobHttpHeaders headers = new BlobHttpHeaders().setContentType(contentType);
            blobClient.setHttpHeaders(headers);
        } catch (IOException e) {
            throw new RuntimeException("Falha ao ler o arquivo para upload.", e);
        }

        String url;
        if (publicBaseUrl != null && !publicBaseUrl.isBlank()) {
            String normalizedKey = blobName.startsWith("/") ? blobName.substring(1) : blobName;
            url = publicBaseUrl + "/" + normalizedKey;
        } else {
            url = containerClient.getBlobClient(blobName).getBlobUrl();
        }

        return new UploadedImage(blobName, url);
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

}
