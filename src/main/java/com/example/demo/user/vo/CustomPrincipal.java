package com.example.demo.user.vo;

import java.security.Principal;

public class CustomPrincipal implements Principal {

    private final UserVO user;

    public CustomPrincipal(UserVO user) {
        this.user = user;
    }

    @Override
    public String getName() {
        return String.valueOf(user.getUserNo()); // userNo를 식별자로 사용
    }

    public UserVO getUserVO() {
        return this.user;
    }
}