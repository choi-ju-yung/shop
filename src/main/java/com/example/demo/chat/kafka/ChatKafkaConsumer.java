package com.example.demo.chat.kafka;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.example.demo.chat.service.ChatService;
import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.config.KafkaConfig;
import com.example.demo.config.RedisPubSubConfig;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChatKafkaConsumer {

    private final ChatService chatService;
    private final RedisTemplate<String, String> chatRedisTemplate;
    private final ObjectMapper objectMapper;

    /**
     * Kafka "chat-messages" 토픽 메시지 수신
     * 1. DB 저장
     * 2. 발신자 이름/시간 조회
     * 3. Redis Publish → RedisSubscriber → STOMP 전송
     */
    @KafkaListener(topics = KafkaConfig.CHAT_TOPIC, groupId = "chat-group")
    public void consumeSendChat(ChatMessage chatMessage) {
        try {
            // 1. DB 저장
            Map<String, Object> map = new HashMap<>();
            map.put("roomId",     chatMessage.getRoomId());
            map.put("senderNo",   chatMessage.getSenderNo());
            map.put("message",    chatMessage.getMessage());
            map.put("receiverNo", chatMessage.getReceiverNo());
            chatService.insertChatMessage(map);

            // 2. DB에서 발신자 이름 + 저장된 시간 조회
            Map<?, ?> info = chatService.getLatestMessageNameTimeInfo(chatMessage.getRoomId());
            chatMessage.setSenderName((String) info.get("NAME"));
            chatMessage.setSentAt((Timestamp) info.get("SENT_AT"));

            // 3. Redis Publish (모든 서버에 브로드캐스트)
            String json = objectMapper.writeValueAsString(chatMessage);
            chatRedisTemplate.convertAndSend(RedisPubSubConfig.CHAT_CHANNEL, json);

        } catch (JsonProcessingException e) {
            log.error("ChatKafkaConsumer JSON 직렬화 오류", e);
        } catch (Exception e) {
            log.error("ChatKafkaConsumer 처리 오류", e);
        }
    }
}
