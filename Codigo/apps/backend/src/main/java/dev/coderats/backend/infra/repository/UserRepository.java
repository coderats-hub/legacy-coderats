package dev.coderats.backend.infra.repository;

import dev.coderats.backend.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.*;

public interface UserRepository extends JpaRepository<User, UUID> {
  Optional<User> findByGithubId(Long githubId);
  Optional<User> findByGithubUser(String githubUser);
}
