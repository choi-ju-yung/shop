package com.example.demo.regist.service;

import java.util.Random;

import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import com.example.demo.authnumber.vo.AuthNumber;
import com.example.demo.regist.dao.EmailDao;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor // 생성자 주입을 임의의 코드없이 자동으로 설정해주는 어노테이션
public class EmailService {

    private final JavaMailSender mailSender;
    private final EmailDao emailDao;
    
    // 인증번호 생성
    public String createCode() {
        StringBuilder code = new StringBuilder();
        Random rnd = new Random();
        for (int i = 0; i < 6; i++) {
            int sel1 = rnd.nextInt(3); // 0:숫자 / 1,2:영어
            if (sel1 == 0) {
                code.append(rnd.nextInt(10));
            } else {
                char ch = (char) (rnd.nextInt(26) + 65); // A~Z
                if (rnd.nextInt(2) == 0) ch = (char) (ch + ('a' - 'A')); // 소문자
                code.append(ch);
            }
        }
        return code.toString();
    }

    // 이메일 발송
    public void sendEmail(String toEmail, String code) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");
        helper.setTo(toEmail);
        helper.setSubject("[Demo] 회원가입 이메일 인증번호");
        helper.setText("<h3>인증 번호 : <span style='color:red'>" + code + "</span></h3>", true);
        mailSender.send(message);
    }
    
    // 회원가입 축하 메일
    public void sendWelcomeEmail(String toEmail, String username) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");
        helper.setTo(toEmail);
        helper.setSubject("[Shop] 회원가입을 축하합니다!");
        helper.setText(
            "<h2>" + username + "님, 가입을 환영합니다! 🎉</h2>" +
            "<p>저희 서비스를 이용해 주셔서 감사합니다.</p>",
            true
        );
        mailSender.send(message);
    }

    public int createAuthNumber(AuthNumber authNumber) {
    	return emailDao.createAuthNumber(authNumber);
    }
    
    public boolean compareAuthNumber(AuthNumber authNumber) {
    	return emailDao.compareAuthNumber(authNumber) > 0;
    }
}
