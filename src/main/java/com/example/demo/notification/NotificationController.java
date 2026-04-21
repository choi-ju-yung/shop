package com.example.demo.notification;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.chat.service.ChatService;
import com.example.demo.user.vo.UserVO;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notiService;
    private final ChatService chatService;

    /** 알림 페이지 */
    @GetMapping("/member/notilist")
    public String notificationsPage(@RequestParam(defaultValue = "1") int page,
                                    HttpSession session, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        long userNo = loginUser.getUserNo();

        PageHelper.startPage(page, 12);
        List<Notification> notifications = notiService.selectNotifications(userNo);
        PageInfo<Notification> pageInfo = new PageInfo<>(notifications);
        int unreadChatCount = chatService.getTotalUnreadCount(userNo);

        model.addAttribute("notifications", notifications);
        model.addAttribute("unreadChatCount", unreadChatCount);
        model.addAttribute("currentPage", pageInfo.getPageNum());
        model.addAttribute("totalPages",  pageInfo.getPages());

        // 페이지 진입 시 읽음 처리
        notiService.markAllAsRead(userNo);

        return "mypage/notifications";
    }

    /**
     * 헤더 배지용 미읽음 카운트 (WISH 알림 + 미읽음 채팅 메시지)
     * 채팅은 NOTIFICATION 테이블이 아닌 CHAT_MESSAGE 테이블 기준
     */
    @GetMapping("/member/notification/count")
    @ResponseBody
    public ResponseEntity<Map<String, Integer>> getUnreadCount(HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        long userNo = loginUser.getUserNo();

        int wishCount = notiService.selectNoReadNotiByN((int) userNo);
        int chatCount = chatService.getTotalUnreadCount(userNo);

        Map<String, Integer> result = new HashMap<>();
        result.put("count", wishCount + chatCount);
        result.put("wishCount", wishCount);
        result.put("chatCount", chatCount);
        return ResponseEntity.ok(result);
    }

    /** 읽음 처리 (WISH 알림만) */
    @PostMapping("/member/notification/read")
    @ResponseBody
    public ResponseEntity<Void> markAllAsRead(HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        notiService.markAllAsRead(loginUser.getUserNo());
        return ResponseEntity.ok().build();
    }
}
