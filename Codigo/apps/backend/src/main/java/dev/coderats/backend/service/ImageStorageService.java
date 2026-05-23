package dev.coderats.backend.service;

import org.springframework.web.multipart.MultipartFile;

/**
 * Abstraction for image storage providers.
 * Implementations must return an {@link UploadedImage} containing the storage key and a public URL.
 */
public interface ImageStorageService {

    UploadedImage upload(MultipartFile file);

}
