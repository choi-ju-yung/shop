package com.example.demo.chat.kafka;

import java.sql.Timestamp;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.example.demo.chat.redis.ChatRedisService;
import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.config.KafkaConfig;
import com.example.demo.config.RedisPubSubConfig;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class ChatKafkaConsumer {

    private final ChatRedisService chatRedisService;
    private final RedisTemplate<String, String> chatRedisTemplate;
    private final ObjectMapper objectMapper;

    public ChatKafkaConsumer(ChatRedisService chatRedisService,
                             @Qualifier("chatRedisTemplate") RedisTemplate<String, String> chatRedisTemplate,
                             ObjectMapper objectMapper) {
        this.chatRedisService  = chatRedisService;
        this.chatRedisTemplate = chatRedisTemplate;
        this.objectMapper      = objectMapper;
    }

    @KafkaListener(topics = KafkaConfig.CHAT_TOPIC, groupId = "chat-group")
    public void consumeSendChat(ChatMessage chatMessage) {
        try {
            // 1. Redis 캐시에서 발신자 이름 조회 (DB 쿼리 없음)
            chatMessage.setSenderName(chatRedisService.getSenderName(chatMessage.getSenderNo()));

            // 2. 현재 시각으로 전송 시간 설정 (DB 쿼리 없음)
            chatMessage.setSentAt(new Timestamp(System.currentTimeMillis()));

            // 3. 미읽음 카운트 증가 - Kafka 소비자에서 1회만 실행 (Redis pub/sub 구독자가 여러 인스턴스면 중복 증가됨)
            int newUnread = chatRedisService.incrementUnread(chatMessage.getRoomId(), chatMessage.getReceiverNo());
            chatMessage.setUnreadCount(newUnread);

            // 3. Redis Publish → RedisSubscriber → 즉시 WebSocket 전송
            // DB 저장은 chat-db-writer 그룹의 ChatDbWriterConsumer가 별도로 처리
            String json = objectMapper.writeValueAsString(chatMessage);
            chatRedisTemplate.convertAndSend(RedisPubSubConfig.CHAT_CHANNEL, json);

        } catch (JsonProcessingException e) {
            log.error("ChatKafkaConsumer JSON 직렬화 오류", e);
        } catch (Exception e) {
            log.error("ChatKafkaConsumer 처리 오류", e);
        }
    }
}
