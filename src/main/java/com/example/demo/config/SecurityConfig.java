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
import com.example.demo.user.service.UserService;

import jakarta.servlet.DispatcherType;
import jakarta.servlet.http.HttpSession;

@Configuration
public class SecurityConfig {

    @Bean
    public HttpFirewall allowDoubleSlashFirewall() {
        DefaultHttpFirewall firewall = new DefaultHttpFirewall();
        firewall.setAllowUrlEncodedSlash(true);
        return firewall;
    }

    @Autowired
    private CustomOAuth2UserService customOAuth2UserService;

    @Autowired
    private CustomAuthFailureHandler customAuthFailureHandler;

    @Autowired
    private UserService userService;

    @Bean
    public WebSecurityCustomizer webSecurityCustomizer() {
        return (web) -> web.ignoring()
                .requestMatchers("/static/**", "/css/**", "/js/**", "/images/**", "/upload/**", "/webjars/**", "/regist/insert");
    }

	// =====================================================
	// URL 권한 목록 - 경로 추가/변경 시 여기서만 관리
	// =====================================================

	// 비로그인도 접근 가능한 공개 경로
	private static final String[] PUBLIC_URLS = {
		"/",
		"/main",
		"/user/main",
		"/login",
		"/logout",
		"/processLogin",
		"/regist/**",
		"/regist/checkWithdraw",
		"/emailDupCheck",
		"/auth/kakao/callback",
		"/popup/**",
		"/find/**",
		"/banner/list",
		"/product/**",
		"/coupon/list",
		"/coupon/*",
		"/user/profile/**",
		"/board/check",
		"/board/checkByCategory",
		"/board/list",
		"/WEB-INF/views/**"
	};

	// 로그인한 일반 유저 + 관리자 접근 가능 경로
	private static final String[] USER_URLS = {
		"/member/**",
		"/ws/**"
	};

	// 관리자만 접근 가능 경로
	private static final String[] ADMIN_URLS = {
		"/admin/**"
	};

	// =====================================================

	@Bean
	public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
		http.csrf(csrf -> csrf.disable())
				.authorizeHttpRequests(auth -> auth
						.requestMatchers(HttpMethod.POST, "/regist/insert").permitAll()
						.dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()
						.requestMatchers(PUBLIC_URLS).permitAll()
						.requestMatchers(ADMIN_URLS).hasRole("ADMIN")
						.requestMatchers(USER_URLS).hasAnyRole("USER", "ADMIN")
		                .requestMatchers("/app/**").permitAll()
		                .anyRequest().authenticated()
				)
				.formLogin(form -> form
						.loginPage("/login")
						.loginProcessingUrl("/processLogin")
						.usernameParameter("loginId")
					    .passwordParameter("password")
						.defaultSuccessUrl("/main", true)
						.failureHandler(customAuthFailureHandler)
						.permitAll())
		        .oauth2Login(oauth2 -> oauth2
		        		.loginPage("/login")
		        		.defaultSuccessUrl("/main", true)
		        		.userInfoEndpoint(userInfo -> userInfo
		        				.userService(customOAuth2UserService)
		        			)
		                .successHandler((request, response, authentication) -> {
		                    if (authentication.getPrincipal() instanceof DefaultOAuth2User oauthUser) {
		                        SecurityContextHolder.clearContext();
		                        HttpSession session = request.getSession();
		                        session.removeAttribute("SPRING_SECURITY_CONTEXT");

		                        String email = (String) oauthUser.getAttribute("email");

		                        // 탈퇴 후 30일 재가입 제한 체크 (이메일 기준)
		                        try {
		                            userService.checkWithdrawRestriction(email, null);
		                        } catch (RuntimeException e) {
		                            response.sendRedirect("/login?error=true&message=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
		                            return;
		                        }

		                        try {
		                            if (userService.emailDupCheck(email) > 0) {
		                                response.sendRedirect("/login?error=true&message=" + URLEncoder.encode("이미 회원가입한 이메일이 존재합니다.", "UTF-8"));
		                                return;
		                            }
		                        } catch (Exception e) {
		                            response.sendRedirect("/login?error=true&message=" + URLEncoder.encode("이메일 확인 중 오류가 발생했습니다.", "UTF-8"));
		                            return;
		                        }

		                        // 카카오 정보를 HTTP 세션에 임시 저장
		                        session.setAttribute("kakaoOauthId", (String) oauthUser.getAttribute("oauthId"));
		                        session.setAttribute("kakaoNickname", (String) oauthUser.getAttribute("nickname"));
		                        session.setAttribute("kakaoEmail", email);
		                        response.sendRedirect("/regist/kakao");
		                    } else {
		                        response.sendRedirect("/main");
		                    }
		                })
		        	)

				 .sessionManagement(session -> session
				            .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
				            .sessionFixation().migrateSession()
				        )

				 .logout(logout -> logout
						    .logoutUrl("/logout")
						    .logoutSuccessHandler((request, response, authentication) -> {

						        HttpSession session = request.getSession(false);
						        if (session != null) {
						            session.invalidate();
						        }
						        SecurityContextHolder.clearContext();

						        String scheme = request.getScheme();
						        int port = request.getServerPort();
						        boolean defaultPort = ("https".equals(scheme) && port == 443) || ("http".equals(scheme) && port == 80);
						        String currentHost = scheme + "://" + request.getServerName() + (defaultPort ? "" : ":" + port);

						        if (authentication == null) {
						            response.sendRedirect(currentHost + "/login");
						            return;
						        }

						        boolean isOauthUser = authentication.getPrincipal() instanceof org.springframework.security.oauth2.core.user.DefaultOAuth2User;

						        if (isOauthUser) {
						            String kakaoLogoutUrl = "https://kauth.kakao.com/oauth/logout" +
						                    "?client_id=" + KakaoConfig.CLIENT_ID +
						                    "&logout_redirect_uri=" + URLEncoder.encode(currentHost + "/login", "UTF-8");
						            response.sendRedirect(kakaoLogoutUrl);
						        } else {
						            response.sendRedirect(currentHost + "/login");
						        }

						    })
						    .invalidateHttpSession(true)
						    .deleteCookies("JSESSIONID")
						    .permitAll()
						);

		return http.build();
	}

}
