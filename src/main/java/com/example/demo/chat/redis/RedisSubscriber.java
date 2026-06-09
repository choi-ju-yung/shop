package com.example.demo.chat.redis;

import java.util.HashMap;
import java.util.Map;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.chat.vo.ChatRoom;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class RedisSubscriber {

    private final SimpMessagingTemplate messagingTemplate;
    private final ChatRedisService chatRedisService;
    private final ObjectMapper objectMapper;

    public void onChatMessage(String message, String channel) {
        try {
            ChatMessage chatMessage = objectMapper.readValue(message, ChatMessage.class);
            String roomId    = chatMessage.getRoomId();
            int senderNo     = chatMessage.getSenderNo();
            int receiverNo   = chatMessage.getReceiverNo();

            // 1. 채팅창에 메시지 즉시 전송 (DB 없음)
            messagingTemplate.convertAndSendToUser(String.valueOf(receiverNo), "/queue/chat/", chatMessage);
            messagingTemplate.convertAndSendToUser(String.valueOf(senderNo),   "/queue/chat/", chatMessage);

            // 2. 채팅 목록 업데이트 - Redis 기반 (DB 쿼리 없음)
            ChatRoom roomBase = chatRedisService.getRoomBase(roomId);
            if (roomBase != null) {
                // 발신자 목록: 미읽음 0, 마지막 메시지 = 방금 보낸 것
                ChatRoom senderRoom = buildChatRoom(roomBase, roomId, chatMessage, receiverNo, 0);
                messagingTemplate.convertAndSend("/topic/chat-list/" + senderNo, senderRoom);

                // 수신자 목록: 미읽음 +1
                int unread = chatRedisService.incrementUnread(roomId, receiverNo);
                ChatRoom receiverRoom = buildChatRoom(roomBase, roomId, chatMessage, senderNo, unread);
                messagingTemplate.convertAndSend("/topic/chat-list/" + receiverNo, receiverRoom);
            }

            // 3. 수신자 알림 토스트
            Map<String, Object> notifyPayload = new HashMap<>();
            notifyPayload.put("notiMessage", chatMessage.getSenderName() + ": " + chatMessage.getMessage());
            notifyPayload.put("type", "MESSAGE");
            messagingTemplate.convertAndSendToUser(String.valueOf(receiverNo), "/queue/notify", notifyPayload);

        } catch (Exception e) {
            log.error("RedisSubscriber onMessage 오류", e);
        }
    }

    private ChatRoom buildChatRoom(ChatRoom base, String roomId, ChatMessage msg, int otherUserNo, int unreadCount) {
        ChatRoom room = new ChatRoom();
        room.setRoomId(roomId);
        room.setProductId(base.getProductId());
        room.setSellerNo(base.getSellerNo());
        room.setBuyerNo(base.getBuyerNo());
        room.setOtherUserNo(otherUserNo);
        room.setLastMessage(msg.getMessage());
        room.setLastMessageTime(msg.getSentAt());
        room.setUnreadCount(unreadCount);
        return room;
    }
}
