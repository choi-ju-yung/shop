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

    private static final String NAME_KEY   = "chat:name:";
    private static final String UNREAD_KEY = "chat:unread:";
    private static final String TOTAL_KEY  = "chat:total:";
    private static final String ROOM_KEY   = "chat:room:";

    private final RedisTemplate<String, String> chatRedisTemplate;
    private final ChatDao chatDao;

    public ChatRedisService(@Qualifier("chatRedisTemplate") RedisTemplate<String, String> chatRedisTemplate,
                            ChatDao chatDao) {
        this.chatRedisTemplate = chatRedisTemplate;
        this.chatDao = chatDao;
    }

    // ────────────── 발신자 이름 캐시 ──────────────

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

    public void evictSenderName(int userNo) {
        chatRedisTemplate.delete(NAME_KEY + userNo);
    }

    // ────────────── 방 기본 정보 캐시 ──────────────

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

    // ────────────── 방별 미읽음 카운트 ──────────────

    /** 채팅 목록 페이지 로드 시 DB 기준으로 Redis 초기화 */
    public void initRoomUnread(String roomId, int userNo, int count) {
        chatRedisTemplate.opsForValue().set(UNREAD_KEY + roomId + ":" + userNo, String.valueOf(count));
    }

    /** 전체 미읽음 합계 초기화 (채팅 목록 페이지 로드 시) */
    public void initTotalUnread(int userNo, int total) {
        chatRedisTemplate.opsForValue().set(TOTAL_KEY + userNo, String.valueOf(total));
    }

    /** 새 메시지 수신 시 미읽음 +1 */
    public int incrementUnread(String roomId, int receiverNo) {
        Long roomVal  = chatRedisTemplate.opsForValue().increment(UNREAD_KEY + roomId + ":" + receiverNo);
        chatRedisTemplate.opsForValue().increment(TOTAL_KEY + receiverNo);
        return roomVal != null ? roomVal.intValue() : 1;
    }

    /** 채팅방 읽음 처리 시 미읽음 초기화 */
    public void resetUnread(String roomId, int userNo) {
        String roomKey = UNREAD_KEY + roomId + ":" + userNo;
        String cur = chatRedisTemplate.opsForValue().get(roomKey);
        int prev = (cur != null) ? Integer.parseInt(cur) : 0;

        chatRedisTemplate.opsForValue().set(roomKey, "0");

        if (prev > 0) {
            String totalKey = TOTAL_KEY + userNo;
            Long newTotal = chatRedisTemplate.opsForValue().decrement(totalKey, prev);
            if (newTotal != null && newTotal < 0) {
                chatRedisTemplate.opsForValue().set(totalKey, "0");
            }
        }
    }

    /** 헤더 배지용 전체 미읽음 카운트 (Redis → DB fallback) */
    public int getTotalUnread(int userNo) {
        String val = chatRedisTemplate.opsForValue().get(TOTAL_KEY + userNo);
        if (val == null) {
            int dbCount = chatDao.getTotalUnreadCount((long) userNo);
            chatRedisTemplate.opsForValue().set(TOTAL_KEY + userNo, String.valueOf(dbCount));
            return dbCount;
        }
        return Math.max(0, Integer.parseInt(val));
    }
}
