package dev.coderats.backend.web.dto.mapper;

import dev.coderats.backend.domain.User;
import dev.coderats.backend.web.dto.response.UserDTO;

/**
 * Mapper para converter entidades User em DTOs seguros.
 * Evita serialização de coleções LAZY e LazyInitializationException.
 */
public class UserMapper {
    
    /**
     * Converte User entity para UserDTO seguro.
     * Apenas campos básicos são copiados, sem coleções.
     * 
     * @param user Entidade User do banco de dados
     * @return UserDTO com dados básicos
     */
    public static UserDTO toDTO(User user) {
        if (user == null) {
            return null;
        }
        
        return new UserDTO(
            user.getId(),
            user.getName(),
            user.getEmail(),
            user.getImage(),
            user.getGithubUser(),
            user.getGithubId(),
            user.getCreatedAt(),
            user.getUpdatedAt()
        );
    }
}
