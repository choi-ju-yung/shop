package com.example.demo.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;

@Component
public class KakaoConfig {
	
	@Value("${spring.security.oauth2.client.registration.kakao.client-id}")
	private String clientId;
	
	@Value("${spring.security.oauth2.client.registration.kakao.redirect-uri}")
	private String redirectUri;
	
	@Value("${spring.security.oauth2.client.provider.kakao.token-uri}")
	private String tokenUri;
	
	@Value("${spring.security.oauth2.client.provider.kakao.user-info-uri}")
	private String userInfoUri;
	
    public static String CLIENT_ID;
    public static String REDIRECT_URI;
    public static String TOKEN_URI;
    public static String USER_INFO_URI;
    
    @PostConstruct
    public void init() {
		CLIENT_ID = this.clientId;
		REDIRECT_URI = this.redirectUri;
		TOKEN_URI = this.tokenUri;   
		USER_INFO_URI = this.userInfoUri;
    }
}
