package com.example.demo.chat.controller;

import java.security.Principal;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.example.demo.chat.redis.ChatRedisService;
import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.config.KafkaConfig;

@Controller
public class ChatMessageController {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private ChatRedisService chatRedisService;

    @Autowired
    private KafkaTemplate<String, ChatMessage> kafkaTemplate;

    /**
     * 메시지 전송 → Kafka로 발행
     * DB저장 / STOMP전송 / 알림은 ChatKafkaConsumer → RedisSubscriber 에서 처리
     */
    @MessageMapping("/chat/send/{roomId}")
    public void sendMessage(@DestinationVariable String roomId,
                            @Payload ChatMessage chatMessage, Principal principal) {
        chatMessage.setRoomId(roomId);
        
        // 사용자에게 직접 메시지를 보내는것이 아님
        // WebSocket으로 받은 메시지를 Kafka chat-messages 토픽에 발행하고 끝.
        kafkaTemplate.send(KafkaConfig.CHAT_TOPIC, chatMessage);
    }

    /**
     * 채팅방 진입 시 읽음 처리
     */
    @MessageMapping("/chat/read")
    public void readMessages(@Payload Map<String, String> payload) {
        String roomId    = payload.get("roomId");
        int userNo       = Integer.parseInt(payload.get("userNo"));
        int otherUserNo  = Integer.parseInt(payload.get("otherUserNo"));

        // Redis 즉시 초기화 (dirty 마킹 → 스케줄러가 1분 내 DB 동기화)
        chatRedisService.resetUnread(roomId, userNo);

        // 헤더 배지 즉시 갱신 (DB 대신 Redis 기준 → async DB 지연 무관)
        int totalUnread = chatRedisService.getTotalUnread(userNo);
        Map<String, Integer> badgePayload = new HashMap<>();
        badgePayload.put("chatCount", totalUnread);
        messagingTemplate.convertAndSendToUser(String.valueOf(userNo), "/queue/badgecount", badgePayload);

        // 발신자(상대방)에게 읽음 확인 → 채팅방 "읽음" 표시
        Map<String, Object> readReceipt = new HashMap<>();
        readReceipt.put("roomId", roomId);
        messagingTemplate.convertAndSendToUser(String.valueOf(otherUserNo), "/queue/read", readReceipt);

        // 내 채팅 목록 미읽음 뱃지 제거
        Map<String, Object> clearBadge = new HashMap<>();
        clearBadge.put("roomId", roomId);
        clearBadge.put("unreadCount", 0);
        messagingTemplate.convertAndSend("/topic/chat-list/" + userNo, clearBadge);
    }
}
