package com.example.demo.mypage.vo;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ProfileUpdateDto {
    private long userNo;
    private String nickname;
    private String introduce;
    private String profileImg; // null이면 이미지 변경 없음
}
