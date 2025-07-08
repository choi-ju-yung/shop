package com.example.demo.regist.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.authnumber.vo.AuthNumber;
import com.example.demo.regist.service.EmailService;

import jakarta.mail.MessagingException;

@RestController
@RequestMapping("/regist")
public class EmailController {
	private final EmailService emailService;
	
	@Autowired
	public EmailController(EmailService emailService) {
		this.emailService = emailService;
	}

	/**
	 * 이메일에 인증번호를 보내고, 인증번호를 디비에 저장하기 
	 */
	@PostMapping("/sendEmail")
	public String sendEmail(@RequestParam("inputEmail") String inputEmail, @RequestParam("requestIp") String userIp) {
		String code = emailService.createCode();
		try {
			emailService.sendEmail(inputEmail, code);
			
			AuthNumber authNumber = AuthNumber.builder()
					.email(inputEmail)
					.authCode(code)
					.requestIp(userIp).build();
			
			int result = emailService.createAuthNumber(authNumber);
					// DB 저장 등 추가 로직 필요시 여기에 작성
			return code; // 또는 "success" 등 원하는 값 반환
		} catch (MessagingException e) {
			e.printStackTrace();
			return "fail";
		}
	}
	
	
	/**
	 * 인증번호가 일치하는지 확인
	 */
	@PostMapping("/compareAuthNumber")
	public boolean compareAuthNumber(@RequestParam("inputEmail") String email, @RequestParam("authCode") String authCode) {
		AuthNumber authNumber = AuthNumber.builder().email(email).authCode(authCode).build();
		
		boolean flag = emailService.compareAuthNumber(authNumber);
		return flag;
	}
	
	
}
