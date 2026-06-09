package com.example.demo.chat.kafka;

import java.util.HashMap;
import java.util.Map;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.example.demo.chat.service.ChatService;
import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.config.KafkaConfig;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChatDbWriterConsumer {

    private final ChatService chatService;

    @KafkaListener(topics = KafkaConfig.CHAT_TOPIC, groupId = "chat-db-writer")
    public void persistToDB(ChatMessage chatMessage) {
        try {
            Map<String, Object> map = new HashMap<>();
            map.put("roomId",     chatMessage.getRoomId());
            map.put("senderNo",   chatMessage.getSenderNo());
            map.put("message",    chatMessage.getMessage());
            map.put("receiverNo", chatMessage.getReceiverNo());
            chatService.insertChatMessage(map);
        } catch (Exception e) {
            log.error("ChatDbWriterConsumer DB 저장 오류", e);
        }
    }
}
