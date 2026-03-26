package com.example.demo;
import java.security.Principal;
import java.util.Map;

import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.support.DefaultHandshakeHandler;

import com.example.demo.user.vo.CustomPrincipal;
import com.example.demo.user.vo.UserVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public class CustomHandshakeHandler extends DefaultHandshakeHandler {

	// WebSocket은 HTTP와 다르게 Spring Security의 SecurityContext를 자동으로 못 씀
	// 웹소켓 연결할때 누가 연결했는지 직접 알려줘야함 
	
	
	/*브라우저가 WebSocket 연결 요청
    		↓
	CustomHandshakeHandler.determineUser() 실행
	        ↓
	HTTP 세션에서 loginUser 꺼냄
	        ↓
	CustomPrincipal로 감싸서 반환
	        ↓
	WebSocket 연결에 사용자 정보 등록
	        ↓
	이후 session.getPrincipal() 로 사용자 식별 가능*/
	
    @Override
    protected Principal determineUser(ServerHttpRequest request, WebSocketHandler wsHandler,
                                      Map<String, Object> attributes) {
        
        HttpServletRequest servletRequest = ((ServletServerHttpRequest) request).getServletRequest();
        HttpSession session = servletRequest.getSession(false);

        if (session == null) return null;

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");

        if (loginUser == null) return null;

        return new CustomPrincipal(loginUser); // ★ 여기!
    }
}	