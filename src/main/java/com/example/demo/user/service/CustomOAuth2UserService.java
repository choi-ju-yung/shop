package com.example.demo.user.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.core.convert.converter.Converter;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import com.example.demo.user.vo.CustomUserDetails;
import com.example.demo.user.vo.UserVO;

import edu.emory.mathcs.backport.java.util.Collections;

@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService{
	
	private final UserService userService;
	
	@Autowired
	public CustomOAuth2UserService(@Lazy UserService userService) {
		this.userService = userService;
	}
	
	@Override
	public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
		
		OAuth2User oAuth2User = super.loadUser(userRequest); // 1. 부모 클래스의 메서드로 기본 OAuth2User 객체 생성
		
        Map<String, Object> kakaoAccount = oAuth2User.getAttribute("kakao_account"); 
        Map<String, Object> profile = (Map<String, Object>) kakaoAccount.get("profile");
        
        String oauthId = oAuth2User.getAttribute("id").toString();
        String nickname = (String) profile.get("nickname");
        String email = (String) kakaoAccount.get("email");
        
        UserVO user = userService.findByKakaoId(oauthId); // DB에서 카카오 사용자 조회
		
        if(user == null) {
        	 UserVO tempUser = new UserVO();
        	 tempUser.setOauthId(oauthId);
        	 tempUser.setUsername(nickname);
        	
        	 Map<String, Object> attributes = new HashMap<>();
             attributes.put("oauthId", oauthId);
             attributes.put("nickname", nickname);
             attributes.put("email", email);
             return new DefaultOAuth2User(Collections.singleton(new SimpleGrantedAuthority("ROLE_USER")), attributes, "oauthId");
        }
        return new CustomUserDetails(user); // 
	}

	
}
