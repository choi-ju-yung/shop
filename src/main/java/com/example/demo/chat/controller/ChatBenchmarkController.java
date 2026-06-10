package com.example.demo.chat.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.chat.dao.ChatDao;
import com.example.demo.chat.redis.ChatRedisService;

import lombok.RequiredArgsConstructor;

/**
 * 채팅 성능 벤치마크: DB 직접 방식 vs Redis write-behind 방식 비교
 * JMeter 부하테스트용 엔드포인트 (/test/bench/**)
 */
@RestController
@RequestMapping("/test/bench")
@RequiredArgsConstructor
public class ChatBenchmarkController {

    private final ChatDao chatDao;
    private final ChatRedisService chatRedisService;

    /**
     * DB 직접 방식 (구버전):
     * INSERT(Oracle COMMIT) + SELECT sender name → 동기 처리
     * 예상 지연: 150~285ms (Oracle redo log I/O)
     */
    @PostMapping("/chat/db")
    @Transactional
    public ResponseEntity<Map<String, Object>> benchmarkDb(
            @RequestParam(defaultValue = "4") String roomId,
            @RequestParam(defaultValue = "15") int senderNo,
            @RequestParam(defaultValue = "16") int receiverNo) {

        long start = System.currentTimeMillis();

        Map<String, Object> map = new HashMap<>();
        map.put("roomId", roomId);
        map.put("senderNo", senderNo);
        map.put("message", "bench");
        map.put("receiverNo", receiverNo);

        chatDao.insertChatMessage(map);             // Oracle INSERT + COMMIT (~150ms)
        chatDao.getSenderNameByUserNo(senderNo);    // SELECT (~5ms)

        long elapsed = System.currentTimeMillis() - start;

        Map<String, Object> result = new HashMap<>();
        result.put("method", "db");
        result.put("elapsed", elapsed);
        return ResponseEntity.ok(result);
    }

    /**
     * Redis write-behind 방식 (신버전):
     * Redis name 조회(캐시) + async DB INSERT → WebSocket 즉시 응답
     * 예상 지연: 1~3ms
     */
    @PostMapping("/chat/redis")
    public ResponseEntity<Map<String, Object>> benchmarkRedis(
            @RequestParam(defaultValue = "4") String roomId,
            @RequestParam(defaultValue = "15") int senderNo,
            @RequestParam(defaultValue = "16") int receiverNo) {

        long start = System.currentTimeMillis();

        chatRedisService.getSenderName(senderNo);   // Redis GET (캐시, ~1ms)
        // async DB INSERT는 Kafka → ChatDbWriterConsumer에서 처리 (non-blocking)

        long elapsed = System.currentTimeMillis() - start;

        Map<String, Object> result = new HashMap<>();
        result.put("method", "redis");
        result.put("elapsed", elapsed);
        return ResponseEntity.ok(result);
    }
}
