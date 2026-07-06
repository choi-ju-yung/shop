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
	private long userNo;
	private String loginId;
	private String password;
	private String nickname;
	private String email;
	private String role;
	private String oauthProvider;
	private String oauthId;
	private Date regDate;


}
