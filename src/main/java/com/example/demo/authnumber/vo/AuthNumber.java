package com.example.demo.authnumber.vo;

import java.sql.Date;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@Data
@NoArgsConstructor
@Builder
public class AuthNumber {
	private String email; // 이메일 주소
	private String authCode; // 인증번호
	private Date createTime; // 인증번호 생성시간
	private String isVerified; // 인증 완료 여부
	private String requestIp; // 인증 요청자의 IP 주소
}
