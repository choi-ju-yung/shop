package com.example.demo.user.service;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.mypage.dao.MyPageDao;
import com.example.demo.mypage.service.MyPageService;
import com.example.demo.user.dao.UserDao;
import com.example.demo.user.exception.UserRegistrationException;
import com.example.demo.user.vo.UserVO;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class UserService {

	private final UserDao userDao;
	private final MyPageDao myPageDao;
	private final PasswordEncoder passwordEncoder;
	
	@Autowired
	public UserService(UserDao userDao, MyPageDao myPageDao, PasswordEncoder passwordEncoder) {
		this.userDao = userDao;
		this.myPageDao = myPageDao;
		this.passwordEncoder = passwordEncoder;
	}

	public UserVO findByKakaoId(String kakaoId) {
		return userDao.findByKakaoId(kakaoId);
	}
	
	public UserVO findByUserNo(long userNo) {
		return userDao.findByUserNo(userNo);
	}
	
	public UserVO findByUserId(String loginId) {
		return userDao.findByUserId(loginId);
	}
	
	public UserVO getUserByUsername(String username) {
		return userDao.getUserByUsername(username);
	}

	// 이메일 중복체크 서비스
	public int emailDupCheck(String memberEmail) throws Exception {
		return userDao.emailDupCheck(memberEmail);
	}

	@Transactional
	public void registKakaoUser(UserVO userVO) {
		
		String encoder = passwordEncoder.encode(userVO.getPassword());
		userVO.setOauthId(userVO.getOauthId());
		userVO.setPassword(encoder);
		userVO.setRole("ROLE_USER");
		userVO.setOauthProvider("kakao");
		
		int result = userDao.registKakaoUser(userVO);
		if (result == 0) {
			log.error("회원정보 등록실패 : {}", userVO);
			throw new RuntimeException("회원정보 등록실패");
		}

		int result2 = myPageDao.registUserPage(userVO.getUserNo());
		if (result2 == 0) {
			log.error("회원페이지 등록실패 : {}", userVO.getUserNo());
			throw new RuntimeException("회원페이지 등록실패");
		}
	}
	
	public int duplicateId(String loginId){
		return userDao.duplicateId(loginId);
	}
	
	/**
	 * 아이디 비번 로그인 처리 
	 */
	/*
	 * public boolean processLogin(UserVO userVO) { String encodePwd =
	 * userDao.findPwdById(userVO.getLoginId()); String inputPwd =
	 * userVO.getPassword();
	 * 
	 * // matches(사용자입력비밀번호 (암호화x) , DB에저장된 암호화된 비밀번호) , matches가 true면 맞게 로그인 성공
	 * false면 비밀번호 틀림 return passwordEncoder.matches(inputPwd, encodePwd); }
	 */
	
}
