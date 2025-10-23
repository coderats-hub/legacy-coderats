package dev.coderats.backend.shared.infra.security;

import java.util.Collection;
import java.util.Collections; 
import java.util.Objects;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import com.fasterxml.jackson.annotation.JsonIgnore;

import dev.coderats.backend.users.domain.UserId;

public class UserPrincipal implements UserDetails {

    private final UserId id;
    private final String email;

    @JsonIgnore 
    private final String password; 

    private final Collection<? extends GrantedAuthority> authorities;

    public UserPrincipal(UserId id, String email, String password) {
        this.id = id;
        this.email = email;
        this.password = password;
        this.authorities = Collections.emptyList(); 
    }
    
    public UserId getUserId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    @JsonIgnore
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return email; 
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserPrincipal that = (UserPrincipal) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}