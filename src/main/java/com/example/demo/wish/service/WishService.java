package com.example.demo.wish.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import com.example.demo.notification.NotificationService;
import com.example.demo.wish.dao.WishDao;
import com.example.demo.wish.vo.WishVO;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class WishService {

    private final WishDao wishDao;
    private final NotificationService notiService;
    private final SimpMessagingTemplate messagingTemplate;

    /**
     * 찜 토글. 찜 추가 시 true, 취소 시 false 반환.
     * 찜 추가 시 판매자에게 WebSocket 알림 전송.
     */
    public boolean toggleWish(long userNo, Long productId, String wishUserName) {
        Map<String, Object> map = new HashMap<>();
        map.put("userNo", userNo);
        map.put("productId", productId);

        boolean alreadyWished = wishDao.isWished(map) > 0;

        if (alreadyWished) {
            wishDao.deleteWish(map);
            return false;
        } else {
            wishDao.insertWish(map);
            sendWishNotification(userNo, productId, wishUserName);
            return true;
        }
    }

    public boolean isWished(long userNo, Long productId) {
        Map<String, Object> map = new HashMap<>();
        map.put("userNo", userNo);
        map.put("productId", productId);
        return wishDao.isWished(map) > 0;
    }

    public List<WishVO> getWishList(long userNo) {
        return wishDao.selectWishList(userNo);
    }

    private void sendWishNotification(long wishUserNo, Long productId, String wishUserName) {
        try {
            long sellerNo = wishDao.selectSellerNo(productId);

            // 자기 상품을 자신이 찜한 경우 알림 생략
            if (sellerNo == wishUserNo) return;

            String message = wishUserName + "님이 내 상품을 찜했습니다.";

            Map<String, Object> notiMap = new HashMap<>();
            notiMap.put("userNo", sellerNo);
            notiMap.put("notiMessage", message);
            notiMap.put("notiUrl", "/product/" + productId);
            notiMap.put("notificationType", "WISH");

            // UPDATE 시도 → 0이면 미읽음 알림 없음(새 알림) → INSERT + WebSocket
            // UPDATE 시도 → 1이면 기존 미읽음 알림 갱신 → WebSocket 스킵
            int updated = notiService.updateUnreadNotification(notiMap);
            if (updated == 0) {
                notiService.insertNotification(notiMap);

                int noReadCnt = notiService.selectNoReadNotiByN((int) sellerNo);
                Map<String, Object> payload = new HashMap<>();
                payload.put("notiMessage", message);
                payload.put("noReadCnt", noReadCnt);
                payload.put("noReadMCnt", 0);
                messagingTemplate.convertAndSendToUser(
                        String.valueOf(sellerNo), "/queue/notify", payload);
            }

        } catch (Exception e) {
            log.error("찜 알림 전송 실패", e);
        }
    }
}
