package com.example.demo.regist.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.regist.dao.RegistDao;
import com.example.demo.regist.service.EmailService;
import com.example.demo.user.vo.UserVO;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class RegistService {
	
	private final RegistDao registDao;
	private final PasswordEncoder passwordEncoder;
	private final EmailService emailService;

	@Autowired
	public RegistService(RegistDao registDao, PasswordEncoder passwordEncoder, EmailService emailService) {
		this.registDao = registDao;
		this.passwordEncoder = passwordEncoder;
		this.emailService = emailService;
	}
	
	@Transactional
	public void nomalInsert(UserVO userVO) {

		if (!emailService.isEmailVerified(userVO.getEmail())) {
			throw new RuntimeException("이메일 인증이 완료되지 않았습니다.");
		}

		String encode = passwordEncoder.encode(userVO.getPassword());
		userVO.setPassword(encode);
		userVO.setRole("ROLE_USER");

		int result = registDao.nomalInsert(userVO);
		if(result == 0) {
			log.error("회원정보 등록실패 : {}", userVO);
			throw new RuntimeException("회원정보 등록실패");
		}
		
		int result2 = registDao.nomalInsertUserPage(userVO);
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
	
}
