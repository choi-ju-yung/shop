package com.example.demo.user.vo;

import java.sql.Date;

import java.io.Serializable;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UserVO implements Serializable {
    private static final long serialVersionUID = 1L;
	private long userNo;          // 내부 회원 번호 (PK)
	private String loginId;  // 일반 로그인 아이디 
	private String password; // 비밀번호
	private String username; // 사용자이름
	private String email; // 이메일
	private String role; // 권한
    private String oauthProvider;  // 소셜 로그인 플랫폼 (kakao, google 등)
    private String oauthId;    // 소셜 로그인 고유 ID
    private Date regDate;    // 가입 일자	
    
	
	/*
	 * public UserVO(Long id, String username, String email, String password, String
	 * role) { this.id = id; this.username = username; this.email = email;
	 * this.password = password; this.role = role; }
	 */
	
	
	
}
