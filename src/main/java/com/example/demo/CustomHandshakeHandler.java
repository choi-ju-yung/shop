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