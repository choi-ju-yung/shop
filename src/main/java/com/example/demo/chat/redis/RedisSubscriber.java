package com.example.demo.chat.redis;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import com.example.demo.chat.service.ChatService;
import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.chat.vo.ChatRoom;
import com.example.demo.notification.NotificationService;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class RedisSubscriber {

    private final SimpMessagingTemplate messagingTemplate;
    private final ChatService chatService;
    private final NotificationService notiService;
    private final ObjectMapper objectMapper;

    /**
     * Redis "chat-channel" 에 메시지가 들어오면 자동 호출
     * RedisPubSubConfig 의 MessageListenerAdapter 가 이 메서드를 지정함
     */
    public void onMessage(String message, String channel) {
        try {
            ChatMessage chatMessage = objectMapper.readValue(message, ChatMessage.class);
            String roomId   = chatMessage.getRoomId();
            int senderNo    = chatMessage.getSenderNo();
            int receiverNo  = chatMessage.getReceiverNo();

            // 1. 수신자 / 발신자 채팅창에 메시지 실시간 전송
            messagingTemplate.convertAndSendToUser(
                    String.valueOf(receiverNo), "/queue/chat/", chatMessage);
            messagingTemplate.convertAndSendToUser(
                    String.valueOf(senderNo),   "/queue/chat/", chatMessage);

            // 2. 채팅 목록 실시간 업데이트 (양쪽 모두)
            Map<String, Object> senderMap = new HashMap<>();
            senderMap.put("roomId", roomId);
            senderMap.put("userNo", senderNo);

            Map<String, Object> receiverMap = new HashMap<>();
            receiverMap.put("roomId", roomId);
            receiverMap.put("userNo", receiverNo);

            List<ChatRoom> senderRooms   = chatService.getSingleChatRoomInfo(senderMap);
            List<ChatRoom> receiverRooms = chatService.getSingleChatRoomInfo(receiverMap);

            if (!senderRooms.isEmpty()) {
                messagingTemplate.convertAndSend("/topic/chat-list/" + senderNo,   senderRooms.get(0));
            }
            if (!receiverRooms.isEmpty()) {
                messagingTemplate.convertAndSend("/topic/chat-list/" + receiverNo, receiverRooms.get(0));
            }

            // 3. 수신자 알림 처리
            Map<String, Object> notiMap = new HashMap<>();
            notiMap.put("userNo",           receiverNo);
            notiMap.put("senderName",        chatMessage.getSenderName());
            notiMap.put("notiMessage",       chatMessage.getSenderName() + "\n[수신메시지]:" + chatMessage.getMessage());
            notiMap.put("notiUrl",           "/chatList");
            notiMap.put("notificationType",  "MESSAGE");
            notiService.insertNotification(notiMap);

            int noReadCnt  = notiService.selectNoReadNotiByN(receiverNo);
            int noReadMCnt = notiService.selectNoReadNotiByNFromM(receiverNo);

            Map<String, Object> notifyPayload = new HashMap<>();
            notifyPayload.put("noReadCnt",   noReadCnt);
            notifyPayload.put("noReadMCnt",  noReadMCnt);
            notifyPayload.put("notiMessage", notiMap.get("notiMessage"));

            messagingTemplate.convertAndSendToUser(
                    String.valueOf(receiverNo), "/queue/notify", notifyPayload);

        } catch (Exception e) {
            log.error("RedisSubscriber onMessage 오류", e);
        }
    }
}
