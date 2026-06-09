package com.example.demo.chat.kafka;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.example.demo.chat.redis.ChatRedisService;
import com.example.demo.chat.service.ChatService;
import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.config.KafkaConfig;
import com.example.demo.config.RedisPubSubConfig;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class ChatKafkaConsumer {

    private final ChatService chatService;
    private final ChatRedisService chatRedisService;
    private final RedisTemplate<String, String> chatRedisTemplate;
    private final ObjectMapper objectMapper;

    public ChatKafkaConsumer(ChatService chatService,
                             ChatRedisService chatRedisService,
                             @Qualifier("chatRedisTemplate") RedisTemplate<String, String> chatRedisTemplate,
                             ObjectMapper objectMapper) {
        this.chatService      = chatService;
        this.chatRedisService = chatRedisService;
        this.chatRedisTemplate = chatRedisTemplate;
        this.objectMapper     = objectMapper;
    }

    @KafkaListener(topics = KafkaConfig.CHAT_TOPIC, groupId = "chat-group")
    public void consumeSendChat(ChatMessage chatMessage) {
        try {
            // 1. Redis 캐시에서 발신자 이름 조회 (DB 쿼리 없음)
            chatMessage.setSenderName(chatRedisService.getSenderName(chatMessage.getSenderNo()));

            // 2. 현재 시각으로 전송 시간 설정 (DB 쿼리 없음)
            chatMessage.setSentAt(new Timestamp(System.currentTimeMillis()));

            // 3. Redis Publish → RedisSubscriber → 즉시 WebSocket 전송
            String json = objectMapper.writeValueAsString(chatMessage);
            chatRedisTemplate.convertAndSend(RedisPubSubConfig.CHAT_CHANNEL, json);

            // 4. Oracle INSERT는 비동기 처리 (응답 지연에 영향 없음)
            Map<String, Object> map = new HashMap<>();
            map.put("roomId",     chatMessage.getRoomId());
            map.put("senderNo",   chatMessage.getSenderNo());
            map.put("message",    chatMessage.getMessage());
            map.put("receiverNo", chatMessage.getReceiverNo());
            chatService.insertChatMessageAsync(map);

        } catch (JsonProcessingException e) {
            log.error("ChatKafkaConsumer JSON 직렬화 오류", e);
        } catch (Exception e) {
            log.error("ChatKafkaConsumer 처리 오류", e);
        }
    }
}
