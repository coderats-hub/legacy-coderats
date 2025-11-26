package dev.coderats.backend.service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.domain.Group;
import dev.coderats.backend.domain.User;
import dev.coderats.backend.infra.repository.GroupRepository;
import dev.coderats.backend.infra.repository.UserRepository;
import dev.coderats.backend.web.dto.mapper.UserMapper;
import dev.coderats.backend.web.dto.response.PublicProfileResponse;
import dev.coderats.backend.web.dto.response.UserDTO;
import dev.coderats.backend.web.dto.response.UserUpdateRequest;
import dev.coderats.backend.web.dto.utils.CommonGroupSummary;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final GroupRepository groupRepository;

    public UserService(UserRepository userRepository, GroupRepository groupRepository) {
        this.userRepository = userRepository;
        this.groupRepository = groupRepository;
    }

    /**
     * Busca o perfil privado e completo de um usuário.
     */
    public UserDTO getUserProfile(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        
        return UserMapper.toDTO(user);
    }

    /**
     * Atualiza o perfil de um usuário.
     */
    @Transactional
    public UserDTO updateUserProfile(UUID userId, UserUpdateRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        // Atualiza apenas os campos que foram fornecidos (lógica de PATCH)
        if (request.name() != null && !request.name().isBlank()) {
            user.setName(request.name());
        }
        if (request.image() != null) {
            user.setImage(request.image());
        }

        User updatedUser = userRepository.save(user);
        return UserMapper.toDTO(updatedUser);
    }

    /**
     * Busca o perfil público de um usuário e os grupos em comum com o usuário logado.
     */
    public PublicProfileResponse getPublicProfile(UUID targetUserId, UUID viewerId) {
        User user = userRepository.findById(targetUserId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        List<CommonGroupSummary> commonGroups = List.of(); // Lista vazia por padrão

        // Só busca grupos em comum se houver um usuário logado (viewerId)
        // e se ele não estiver olhando o próprio perfil
        if (viewerId != null && !viewerId.equals(targetUserId)) {
            
            // Este método deve existir no seu GroupRepository
            List<Group> groups = groupRepository.findCommonGroups(viewerId, targetUserId);
            
            commonGroups = groups.stream()
                .map(group -> new CommonGroupSummary(group.getId(), group.getName(), group.getImage()))
                .collect(Collectors.toList());
        }

        // Mapeia para o DTO de resposta pública
        return new PublicProfileResponse(
            user.getId(),
            user.getName(),
            user.getImage(),
            commonGroups
            // Corrigido: Campo 'bio' removido
        );
    }
}