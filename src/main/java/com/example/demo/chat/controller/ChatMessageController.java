package com.example.demo.chat.controller;

import java.security.Principal;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.example.demo.chat.service.ChatService;
import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.chat.vo.ChatRoom;
import com.example.demo.notification.NotificationService;
import com.example.demo.user.vo.UserVO;

import jakarta.servlet.http.HttpSession;

@Controller
public class ChatMessageController {
	
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    
    @Autowired
    private ChatService chatService;
    
    @Autowired
    private NotificationService notiService;
    
    /**
     * @param roomId
     * @param chatMessage
     */


    public void sendMessage(@DestinationVariable String roomId, ChatMessage chatMessage, Principal principal) {
    	
        Map map = new HashMap();
        map.put("roomId", roomId);
        map.put("senderNo", chatMessage.getSenderNo());
        map.put("message", chatMessage.getMessage());
        map.put("receiverNo", chatMessage.getReceiverNo());
        
        int result = chatService.insertChatMessage(map); // 메시지 테이블 생성
        
        Map m = chatService.getLatestMessageNameTimeInfo(roomId); // 방ID로 사용자이름, 메시지 보낸 날짜 조회
        chatMessage.setSenderName((String) m.get("NAME"));
        chatMessage.setSentAt((Timestamp) (m.get("SENT_AT")));

        messagingTemplate.convertAndSendToUser(String.valueOf(chatMessage.getReceiverNo()),"/queue/chat/", chatMessage);
        
        Map<String, Object> map2 = new HashMap();
        map2.put("roomId", roomId);
        map2.put("userNo", chatMessage.getSenderNo());
        Map map3 = new HashMap();
        map3.put("roomId", roomId);
        map3.put("userNo", chatMessage.getReceiverNo());
        ChatRoom rooms = chatService.getSingleChatRoomInfo(map2).get(0);
        ChatRoom rooms2 = chatService.getSingleChatRoomInfo(map3).get(0);
        
        messagingTemplate.convertAndSend("/topic/chat-list/" + chatMessage.getSenderNo(), rooms);
        messagingTemplate.convertAndSend("/topic/chat-list/" + chatMessage.getReceiverNo(), rooms2);
        
        Map<String, Object> notiMap = new HashMap<>();
        notiMap.put("userNo", chatMessage.getReceiverNo()); // 받는 사람 번호
        notiMap.put("senderName", chatMessage.getSenderName()); // 보내는사람 이름
        notiMap.put("notiMessage", chatMessage.getSenderName()+"\n"+"[수신메시지]:"+ chatMessage.getMessage()); // 알림메시지
        notiMap.put("notiUrl", "/chatList");
        notiMap.put("notificationType", "MESSAGE");
        
        notiService.insertNotification(notiMap); // 알림 메시지 추가
        int noReadCnt = notiService.selectNoReadNotiByN(chatMessage.getReceiverNo()); // 읽지않은 모든 알림 개수 조회
        int noReadMCnt = notiService.selectNoReadNotiByNFromM(chatMessage.getReceiverNo()); // 읽지않은 메시지 알림 개수 조회
        
        Map<String, Object> returnMap = new HashMap<>();
        returnMap.put("noReadCnt", noReadCnt);
        returnMap.put("noReadMCnt", noReadMCnt);
        returnMap.put("notiMessage", notiMap.get("notiMessage"));
        //convertAndSend 랑 
        
        String name = principal.getName();
        messagingTemplate.convertAndSendToUser(String.valueOf(chatMessage.getReceiverNo()),"/queue/notify", returnMap);
    }
    
    
    /**
     * 채팅방들어갔을때 채팅리스트에서 메시지 읽음처리
     */
    @MessageMapping("/chat/read")
    public void readMessages(@Payload Map<String, String> payload) {
        String roomId = (String) payload.get("roomId");
        int userNo = Integer.parseInt(payload.get("userNo")); 

        Map<String, Object> readMap = new HashMap<>();
        readMap.put("roomId", roomId);
        readMap.put("userNo", userNo);

        // DB에서 읽음 처리
        chatService.markMessagesAsRead(roomId, userNo);
        
        // 갱신된 채팅 리스트 전송
        ChatRoom rooms = chatService.getSingleChatRoomInfo(readMap).get(0);
        messagingTemplate.convertAndSend("/topic/chat-list/" + userNo, rooms);
    }
}
