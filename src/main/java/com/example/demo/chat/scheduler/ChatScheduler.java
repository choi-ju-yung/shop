package com.example.demo.chat.scheduler;

import java.sql.Timestamp;
import java.util.Set;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.example.demo.chat.redis.ChatRedisService;
import com.example.demo.chat.service.ChatService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
@RequiredArgsConstructor
public class ChatScheduler {

    private final ChatRedisService chatRedisService;
    private final ChatService chatService;

    @Scheduled(fixedDelay = 60000)
    public void flushUnreadToDB() {
        Set<String> dirtyReads = chatRedisService.popDirtyReads();
        if (dirtyReads.isEmpty()) return;

        for (String entry : dirtyReads) {
            try {
                String[] parts  = entry.split(":");
                String roomId   = parts[0];
                int userNo      = Integer.parseInt(parts[1]);
                Timestamp readAt = new Timestamp(Long.parseLong(parts[2]));
                chatService.markMessagesAsRead(roomId, userNo, readAt);
            } catch (Exception e) {
                log.error("미읽음 DB 동기화 실패: {}", entry, e);
            }
        }
        log.info("미읽음 DB 동기화 완료: {}건", dirtyReads.size());
    }
}
