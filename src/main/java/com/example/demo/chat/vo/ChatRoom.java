package com.example.demo.chat.vo;

import java.sql.Date;
import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
@Builder
public class ChatRoom {
    private String roomId;  // 방아이디
    private int productId; // 상품아이디
    private int sellerNo;  // 판매자
    private int buyerNo;  // 구매자
    private Date createdAt; // 방 생성날짜

    // 조회 시 추가로 필요한 필드
    private int unreadCount;      // 안 읽은 메시지 수
    private String otherUserName; // 상대방 이름 (선택사항)
    private String productTitle;  // 상품 제목 (선택사항)
    private int otherUserNo;  // 상대방 번호
    
    // ⭐ 추가된 필드
    private String lastMessage;     // 최신 메시지 내용 (SQL: LAST_MESSAGE)
    private Timestamp lastMessageTime; // 최신 메시지 시간 (SQL: LAST_MESSAGE_TIME)
    private String productImg;      // 상품 대표 이미지 경로
    private String otherUserImg;    // 상대방 프로필 이미지
    private String productPlace;    // 상품 거래지역
}	
