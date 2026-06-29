package com.example.demo.user.service;

import java.sql.Timestamp;
import java.util.UUID;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.mypage.dao.MyPageDao;
import com.example.demo.notification.NotificationDao;
import com.example.demo.productregist.dao.ProductRegistDao;
import com.example.demo.user.dao.UserDao;
import com.example.demo.user.exception.UserRegistrationException;
import com.example.demo.user.vo.UserVO;
import com.example.demo.wish.dao.WishDao;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class UserService {

	private final UserDao userDao;
	private final MyPageDao myPageDao;
	private final PasswordEncoder passwordEncoder;
	private final com.example.demo.regist.service.EmailService emailService;
	private final ProductRegistDao productRegistDao;
	private final WishDao wishDao;
	private final NotificationDao notificationDao;

	@Autowired
	public UserService(UserDao userDao, MyPageDao myPageDao, PasswordEncoder passwordEncoder,
			com.example.demo.regist.service.EmailService emailService,
			ProductRegistDao productRegistDao, WishDao wishDao, NotificationDao notificationDao) {
		this.userDao = userDao;
		this.myPageDao = myPageDao;
		this.passwordEncoder = passwordEncoder;
		this.emailService = emailService;
		this.productRegistDao = productRegistDao;
		this.wishDao = wishDao;
		this.notificationDao = notificationDao;
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
	
	// 이메일 중복체크 서비스
	public int emailDupCheck(String memberEmail) throws Exception {
		return userDao.emailDupCheck(memberEmail);
	}

	@Transactional
	public void registKakaoUser(UserVO userVO) {
		
		userVO.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));
		userVO.setRole("ROLE_USER");
		userVO.setOauthProvider("kakao");
		
		int result = userDao.registKakaoUser(userVO);
		if (result == 0) {
			log.error("회원정보 등록실패 : {}", userVO);
			throw new RuntimeException("회원정보 등록실패");
		}

		int result2 = myPageDao.registUserPage(java.util.Map.of("userNo", userVO.getUserNo(), "nickname", userVO.getNickname()));
		if (result2 == 0) {
			log.error("회원페이지 등록실패 : {}", userVO.getUserNo());
			throw new RuntimeException("회원페이지 등록실패");
		}

		try {
			emailService.sendWelcomeEmail(userVO.getEmail(), userVO.getNickname());
		} catch (Exception e) {
			log.warn("축하 메일 발송 실패 (회원가입은 완료): {}", e.getMessage());
		}
	}
	
	public int duplicateId(String loginId){
		return userDao.duplicateId(loginId);
	}

	@Transactional
	public void withdrawUser(long userNo) {
		// 1. 개인정보 별도 보관 (개인정보보호법 5년 보관 의무)
		userDao.archiveWithdrawnUser(userNo);
		// 2. 내 상품을 찜한 다른 사람들의 찜 삭제
		productRegistDao.deleteWishlistByUserProducts(userNo);
		// 3. 내 상품 소프트 딜리트
		productRegistDao.softDeleteProductsByUserNo(userNo);
		// 4. 내가 찜한 목록 삭제
		wishDao.deleteWishlistByUserNo(userNo);
		// 5. 내 알림 삭제
		notificationDao.deleteNotificationsByUserNo(userNo);
		// 6. USERS_TB 개인정보 익명화 + 소프트 딜리트 (CHAT은 "탈퇴한 사용자"로 표시됨)
		userDao.withdrawUser(userNo);
	}
	
	/**
	 * 탈퇴 후 30일 재가입 제한 체크
	 * 제한 중이면 사용자에게 보여줄 메시지를 RuntimeException으로 throw
	 * 허용 상태면 조용히 반환
	 */
	public void checkWithdrawRestriction(String email, String loginId) {
		Timestamp withdrawnAt = userDao.findWithdrawRestriction(email, loginId);
		if (withdrawnAt == null) return;

		LocalDateTime availableDate = withdrawnAt.toLocalDateTime().plusDays(30);
		String availableDateStr = availableDate.format(DateTimeFormatter.ofPattern("yyyy년 MM월 dd일"));
		throw new RuntimeException("탈퇴 후 30일간 재가입이 제한됩니다. 재가입 가능일: " + availableDateStr);
	}

	/** 아이디 찾기: 이메일 → 로그인 아이디 반환 (없으면 null) */
	public String findLoginId(String email) {
		return userDao.findLoginIdByEmail(email);
	}

	/** 비밀번호 찾기: 임시 비밀번호 발급 후 이메일 발송 */
	@Transactional
	public boolean resetPassword(String loginId, String email) {
		UserVO user = userDao.findUserByLoginIdAndEmail(loginId, email);
		if (user == null) return false;

		String tempPwd = generateTempPassword();
		String encoded = passwordEncoder.encode(tempPwd);
		userDao.updatePassword(loginId, encoded);

		try {
			emailService.sendTempPasswordEmail(email, tempPwd);
		} catch (Exception e) {
			log.warn("임시 비밀번호 메일 발송 실패: {}", e.getMessage());
			throw new RuntimeException("메일 발송에 실패했습니다. 다시 시도해주세요.");
		}
		return true;
	}

	private String generateTempPassword() {
		String chars = "ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#$";
		StringBuilder sb = new StringBuilder();
		java.util.Random rnd = new java.util.Random();
		for (int i = 0; i < 10; i++) {
			sb.append(chars.charAt(rnd.nextInt(chars.length())));
		}
		return sb.toString();
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
