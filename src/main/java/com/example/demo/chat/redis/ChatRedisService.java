package com.example.demo.chat.redis;

import java.time.Duration;
import java.util.Map;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import com.example.demo.chat.dao.ChatDao;
import com.example.demo.chat.vo.ChatRoom;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class ChatRedisService {

    private static final String NAME_KEY    = "chat:name:";
    private static final String UNREAD_KEY  = "chat:unread:";
    private static final String ROOM_KEY    = "chat:room:";

    private final RedisTemplate<String, String> chatRedisTemplate;
    private final ChatDao chatDao;

    public ChatRedisService(@Qualifier("chatRedisTemplate") RedisTemplate<String, String> chatRedisTemplate,
                            ChatDao chatDao) {
        this.chatRedisTemplate = chatRedisTemplate;
        this.chatDao = chatDao;
    }

    /** 발신자 표시 이름 조회 (Redis → DB fallback) */
    public String getSenderName(int userNo) {
        String key = NAME_KEY + userNo;
        String name = chatRedisTemplate.opsForValue().get(key);
        if (name == null) {
            name = chatDao.getSenderNameByUserNo(userNo);
            if (name != null) {
                chatRedisTemplate.opsForValue().set(key, name, Duration.ofHours(24));
            }
        }
        return name != null ? name : "알 수 없음";
    }

    /** 발신자 이름 캐시 갱신 (닉네임 변경 시 호출) */
    public void evictSenderName(int userNo) {
        chatRedisTemplate.delete(NAME_KEY + userNo);
    }

    /** 방 기본 정보 조회 (Redis → DB fallback, 첫 조회만 DB) */
    public ChatRoom getRoomBase(String roomId) {
        String key = ROOM_KEY + roomId;
        Map<Object, Object> cached = chatRedisTemplate.opsForHash().entries(key);
        if (!cached.isEmpty()) {
            ChatRoom room = new ChatRoom();
            room.setRoomId(roomId);
            room.setProductId(Integer.parseInt((String) cached.get("productId")));
            room.setSellerNo(Integer.parseInt((String) cached.get("sellerNo")));
            room.setBuyerNo(Integer.parseInt((String) cached.get("buyerNo")));
            return room;
        }
        ChatRoom room = chatDao.getRoomBaseInfo(roomId);
        if (room != null) {
            chatRedisTemplate.opsForHash().put(key, "productId", String.valueOf(room.getProductId()));
            chatRedisTemplate.opsForHash().put(key, "sellerNo",  String.valueOf(room.getSellerNo()));
            chatRedisTemplate.opsForHash().put(key, "buyerNo",   String.valueOf(room.getBuyerNo()));
            chatRedisTemplate.expire(key, Duration.ofDays(30));
        }
        return room;
    }

    /** 수신자 미읽음 카운트 +1 (key 없으면 DB에서 초기화 후 증가) */
    public int incrementUnread(String roomId, int receiverNo) {
        String key = UNREAD_KEY + roomId + ":" + receiverNo;
        if (!Boolean.TRUE.equals(chatRedisTemplate.hasKey(key))) {
            int dbCount = chatDao.getUnreadCountForReceiver(roomId, receiverNo);
            chatRedisTemplate.opsForValue().setIfAbsent(key, String.valueOf(dbCount));
        }
        Long val = chatRedisTemplate.opsForValue().increment(key);
        return val != null ? val.intValue() : 1;
    }

    /** 채팅방 읽음 처리 시 미읽음 카운트 초기화 */
    public void resetUnread(String roomId, int userNo) {
        chatRedisTemplate.opsForValue().set(UNREAD_KEY + roomId + ":" + userNo, "0");
    }
}
