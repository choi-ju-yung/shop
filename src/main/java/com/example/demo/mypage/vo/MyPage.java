package com.example.demo.mypage.vo;

import com.example.demo.user.vo.UserVO;

import lombok.Data;

@Data
public class MyPage {
	
	private long userNo;
    private String nickname;
    private String profileImg; // 프로필 이미지처럼 단순히 보여주기만 하는 경우라면, 저장 파일명만 관리하는 것이 더 효율적
    private String introduce;
    private double temperature; // 실무에서는 숫자만 저장하고 등급은 코드에서 계산하는 것이 더 일반적
    
    
    // JOIN으로 가져올 USERS 필드
    private String email;
    private String loginId;
    private String oauthProvider;
}
