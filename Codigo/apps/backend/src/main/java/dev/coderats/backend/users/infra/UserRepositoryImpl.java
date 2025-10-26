package dev.coderats.backend.users.infra;

import java.util.Optional;

import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.users.app.port.UserRepository;
import dev.coderats.backend.users.domain.User;
import dev.coderats.backend.users.domain.UserId;
import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class UserRepositoryImpl implements UserRepository {
    
    private final UserJpaRepository jpaRepository;
    private final UserMapper mapper;

    @Override
    @Transactional
    public void save(User user) {
        UserEntity entity = jpaRepository.findById(user.id().asUuid())
            .orElseGet(() -> mapper.toNewEntity(user));
            
        mapper.toEntity(user, entity);
        
        jpaRepository.save(entity);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findById(UserId userId) {
        return jpaRepository.findById(userId.asUuid())
            .map(mapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findByEmail(String email) {
        return jpaRepository.findByEmail(email)
            .map(mapper::toDomain);
    }

    @Override
    @Transactional
    public void saveNewUserWithPassword(User user, String hashedPassword) {
        UserEntity entity = mapper.toNewEntity(user);
        entity.setPassword(hashedPassword); 
        jpaRepository.save(entity);
    }
}