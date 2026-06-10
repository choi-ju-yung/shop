package com.example.demo.user.vo;

import java.io.Serializable;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User;

public class CustomUserDetails implements UserDetails, OAuth2User, Serializable {
    private static final long serialVersionUID = 1L;
	
	private final UserVO user;
	private Map<String, Object> attributes;
	
	 // 일반 로그인 생성자
	public CustomUserDetails(UserVO user) {
		this.user = user;
	}
	
	// OAuth2 로그인 생성자
    public CustomUserDetails(UserVO user, Map<String, Object> attributes) {
        this.user = user;
        this.attributes = attributes;
    }
	

	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		return Collections.singleton(new SimpleGrantedAuthority(user.getRole()));
	}

	public UserVO getUser() {
		return user;
	}

	@Override
	public String getPassword() {
		return user.getPassword();
	}

	@Override
	public String getUsername() {
		return user.getUsername();
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
	public Map<String, Object> getAttributes() {
		return attributes != null ? attributes : new HashMap<>();
	}

	@Override
	public String getName() {
		return user.getUsername();
	}

	@Override
	public boolean isCredentialsNonExpired() {
		return true;
	}

	@Override
	public boolean isEnabled() {
		return true;
	}
}