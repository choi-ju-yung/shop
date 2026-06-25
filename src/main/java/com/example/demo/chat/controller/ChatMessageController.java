package com.example.demo.chat.controller;

import java.security.Principal;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.example.demo.chat.redis.ChatRedisService;
import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.config.KafkaConfig;
import com.example.demo.config.RedisPubSubConfig;

import lombok.extern.slf4j.Slf4j;
import com.fasterxml.jackson.databind.ObjectMapper;

@Slf4j
@Controller
public class ChatMessageController {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private ChatRedisService chatRedisService;

    @Autowired
    private KafkaTemplate<String, ChatMessage> kafkaTemplate;

    @Autowired
    @Qualifier("chatRedisTemplate")
    private RedisTemplate<String, String> chatRedisTemplate;

    @Autowired
    private ObjectMapper objectMapper;

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
     * 타이핑 상태 전달 → Redis pub/sub 경유 (Kafka 불필요, 실시간 이벤트)
     */
    @MessageMapping("/chat/typing/{roomId}")
    public void sendTyping(@DestinationVariable String roomId,
                           @Payload Map<String, Object> payload) {
        payload.put("roomId", roomId);
        try {
            chatRedisTemplate.convertAndSend(RedisPubSubConfig.TYPING_CHANNEL,
                    objectMapper.writeValueAsString(payload));
        } catch (Exception e) {
            log.error("typing 전송 오류", e);
        }
    }

    /**
     * 채팅방 진입 시 읽음 처리
     */
    @MessageMapping("/chat/read")
    public void readMessages(@Payload Map<String, String> payload) {
        String roomId   = payload.get("roomId");
        int userNo      = Integer.parseInt(payload.get("userNo"));
        int otherUserNo = Integer.parseInt(payload.get("otherUserNo"));

        chatRedisService.resetUnread(roomId, userNo);

        // 수신자 배지 갱신 (같은 서버에 연결돼 있으므로 직접 전송)
        int totalUnread = chatRedisService.getTotalUnread(userNo);
        Map<String, Integer> badgePayload = new HashMap<>();
        badgePayload.put("chatCount", totalUnread);
        messagingTemplate.convertAndSendToUser(String.valueOf(userNo), "/queue/badgecount", badgePayload);

        // 발신자가 다른 서버에 연결됐을 수 있으므로 Redis pub/sub으로 브로드캐스트
        try {
            Map<String, Object> receiptData = new HashMap<>();
            receiptData.put("roomId", roomId);
            receiptData.put("targetUserNo", otherUserNo);
            chatRedisTemplate.convertAndSend(RedisPubSubConfig.READ_RECEIPT_CHANNEL,
                    objectMapper.writeValueAsString(receiptData));
        } catch (Exception e) {
            // fallback: 같은 서버에 있으면 직접 전송
            Map<String, Object> readReceipt = new HashMap<>();
            readReceipt.put("roomId", roomId);
            messagingTemplate.convertAndSendToUser(String.valueOf(otherUserNo), "/queue/read", readReceipt);
        }

        // 내 채팅 목록 미읽음 뱃지 제거
        Map<String, Object> clearBadge = new HashMap<>();
        clearBadge.put("roomId", roomId);
        clearBadge.put("unreadCount", 0);
        messagingTemplate.convertAndSend("/topic/chat-list/" + userNo, clearBadge);
    }
}
