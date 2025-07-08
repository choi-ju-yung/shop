package com.example.demo.regist.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.regist.dao.RegistDao;
import com.example.demo.user.vo.UserVO;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class RegistService {
	
	private final RegistDao registDao;
	
	private final PasswordEncoder passwordEncoder;
	
	@Autowired
	public RegistService(RegistDao registDao,PasswordEncoder passwordEncoder) {
		this.registDao = registDao;
		this.passwordEncoder = passwordEncoder;
	}
	
	@Transactional
	public void nomalInsert(UserVO userVO) {
				
		String encode = passwordEncoder.encode(userVO.getPassword());
		userVO.setPassword(encode);
		userVO.setRole("ROLE_USER");
		
		int result = registDao.nomalInsert(userVO);
		if(result == 0) {
			log.error("회원정보 등록실패 : {}", userVO);
			throw new RuntimeException("회원정보 등록실패");
		}
		
		int result2 = registDao.nomalInsertUserPage(userVO.getUserNo());
		if (result2 == 0) {
			log.error("회원페이지 등록실패 : {}", userVO.getUserNo());
			throw new RuntimeException("회원페이지 등록실패");
		}
	}
	
}
