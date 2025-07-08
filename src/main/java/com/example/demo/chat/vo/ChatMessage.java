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
public class ChatMessage {
	
    private int msgId; // 메시지 아이디	
    private String roomId; // 방 아이디
    private int senderNo; // 보내는 사람 번호
    private int receiverNo; // 받는 사람 번호
    private String message; // 보내는 메시지
    private Timestamp sentAt; // 보낸 날짜
    private String isRead; // 읽음 유무
   
    // 추가로 필요한 경우
    private String senderName;  // 보낸 사람 이름 (선택사항)

}
