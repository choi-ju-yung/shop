package com.example.demo.user.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.example.demo.user.vo.CustomUserDetails;
import com.example.demo.user.vo.UserVO;
 
@Service
public class CustomUserDetailsService implements UserDetailsService {
	
    private final UserService userService;

    @Autowired
    public CustomUserDetailsService(UserService userService) {
        this.userService = userService;
    }
	
	@Override
	public UserDetails loadUserByUsername(String loginId) throws UsernameNotFoundException {
		UserVO user = userService.findByUserId(loginId);
        if (user == null) {
            throw new UsernameNotFoundException("User not found: " + loginId);
        }
        return new CustomUserDetails(user);
	}
}
