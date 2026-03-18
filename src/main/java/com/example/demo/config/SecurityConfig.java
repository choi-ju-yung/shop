package com.example.demo.config;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.firewall.DefaultHttpFirewall;
import org.springframework.security.web.firewall.HttpFirewall;
import org.springframework.security.web.firewall.StrictHttpFirewall;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

import com.example.demo.user.controller.CustomAuthFailureHandler;
import com.example.demo.user.service.CustomOAuth2UserService;

import jakarta.servlet.DispatcherType;
import jakarta.servlet.http.HttpSession;

@Configuration
public class SecurityConfig {
	
    @Bean
    public HttpFirewall allowDoubleSlashFirewall() {
        DefaultHttpFirewall firewall = new DefaultHttpFirewall();
        firewall.setAllowUrlEncodedSlash(true); // URL에 인코딩된 슬래시 허용
        return firewall;
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Autowired
    private CustomOAuth2UserService customOAuth2UserService;
    
    @Autowired
    private CustomAuthFailureHandler customAuthFailureHandler;
    
    @Bean
    public WebSecurityCustomizer webSecurityCustomizer() {
        return (web) -> web.ignoring()
                .requestMatchers("/static/**", "/css/**", "/js/**", "/images/**", "/webjars/**", "/regist/insert");
    }
    
	@Bean
	public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
		http.csrf(csrf -> csrf.disable()) // CSRF 보호 비활성화 (필요에 따라 설정)
				.authorizeHttpRequests(auth -> auth // 변경된 메서드 사용
						.requestMatchers(HttpMethod.POST, "/regist/insert").permitAll() // post 설정 허용
						.dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()
						.requestMatchers("/login","/WEB-INF/views/**","/auth/kakao/callback","/logout","/emailDupCheck","/regist/**","/processLogin","/checkTimeBoard/**","/checkTimeBoardByCategory/**").permitAll()
						.requestMatchers("/popup/**").permitAll()
						// 상품 조회/검색/카테고리는 비로그인도 허용
						.requestMatchers("/user/mainProducts","/user/product/**","/user/search","/user/category","/user/headercategories").permitAll()
		                .requestMatchers("/admin/**").hasRole("ADMIN")
		                .requestMatchers("/user/**").hasAnyRole("USER", "ADMIN")
		                .requestMatchers("/chat/**").hasAnyRole("USER", "ADMIN")
		                .requestMatchers("/room/**").hasAnyRole("USER", "ADMIN")
		                .requestMatchers("/app/**").permitAll()
		                .requestMatchers("/ws/**").hasAnyRole("USER", "ADMIN")
		                
		                
						//.requestMatchers("/**").permitAll() // 인증없이 접근가능
						//.requestMatchers("/", "/login").permitAll()
		                .anyRequest().authenticated() // 나머지는 인증 필요
				)/* .formLogin(form -> form.disable()) */
				.formLogin(form -> form
						.loginPage("/login") // 우리가 만든 로그인 페이지 사용 
						.loginProcessingUrl("/processLogin") // 로그인 처리 URL 변경
						.usernameParameter("loginId")
					    .passwordParameter("password")
						.defaultSuccessUrl("/user/main",true) // 로그인 성공 후 이동할 페이지
						.failureHandler(customAuthFailureHandler)
						.permitAll())
		        .oauth2Login(oauth2 -> oauth2
		        		.loginPage("/login")
		        		.defaultSuccessUrl("/user/main",true)
		        		.userInfoEndpoint(userInfo -> userInfo
		        				.userService(customOAuth2UserService)
		        			)
		                .successHandler((request, response, authentication) -> {
		                    // 회원가입 필요 여부 확인
		                    if (authentication.getPrincipal() instanceof DefaultOAuth2User) {
		                        response.sendRedirect("/regist/kakao");
		                    } else {
		                        response.sendRedirect("/user/main");
		                    }
		                })
		        	)

				
				 .sessionManagement(session -> session
				            .sessionCreationPolicy(SessionCreationPolicy.ALWAYS) // 🔥 로그인 상태 유지
				            .sessionFixation().migrateSession()
				        )

				 .logout(logout -> logout
						    .logoutUrl("/logout") // 로그아웃을 수행할 엔드포인트 URL을 지정 (사용자가 /logout으로 접속하면 이 설정이 실행)
						    .logoutSuccessHandler((request, response, authentication) -> { // 로그아웃이 성공적으로 처리된 후 실행되는 직접 구현한 로직
						    	
						        // 현재 세션 종료 및 인증 해제
						        HttpSession session = request.getSession(false);
						        if (session != null) { // 현재 세션이 존재하면
						            session.invalidate();  // 세션을 강제로 무효화
						        }
						        SecurityContextHolder.clearContext(); // Spring Security의 SecurityContext (로그인 정보 저장소) 를 초기화
						        
						        // 로그아웃 후 리다이렉트 주소에 사용하기 위해 서버의 주소를 동적으로 생성
						        String currentHost = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort();

						        // 인증이 null인 경우 → 로그인 상태 아님 → 그냥 로그인 페이지로 보냄
						        if (authentication == null) {
						            response.sendRedirect(currentHost + "/login"); // /login 페이지로 리다이렉트
						            return;
						        }

						        // OAuth 로그인인지 확인 (카카오/구글 같은 OAuth2 로그인 사용자일 경우 true)
						        boolean isOauthUser = authentication.getPrincipal() instanceof org.springframework.security.oauth2.core.user.DefaultOAuth2User;

						        if (isOauthUser) {
						            // 🔒 카카오 로그아웃 URL로 리다이렉트
						            String kakaoLogoutUrl = "https://kauth.kakao.com/oauth/logout" +
						                    "?client_id=" + KakaoConfig.CLIENT_ID +
						                    "&logout_redirect_uri=" + URLEncoder.encode(currentHost + "/login", "UTF-8");
						            response.sendRedirect(kakaoLogoutUrl);
						        } else {
						            // 일반 로그인 사용자 → 일반 로그아웃 처리
						            response.sendRedirect(currentHost + "/login");
						        }

						    })
						    .invalidateHttpSession(true) // true -> 로그아웃 시 세션을 자동으로 무효화 (위에서 수동으로 했지만 이중으로 함)
						    .deleteCookies("JSESSIONID") // 로그아웃할 때 클라이언트에 저장된 세션 쿠키(JSESSIONID) 도 삭제 (보안을 위해서)
						    .permitAll()  // 누구나 접근 가능 
						);
						
		return http.build();
	}
	
} 
