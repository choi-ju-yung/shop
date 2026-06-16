package com.example.demo.chat.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.chat.redis.ChatRedisService;
import com.example.demo.chat.service.ChatService;
import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.chat.vo.ChatRoom;
import com.example.demo.mypage.service.MyPageService;
import com.example.demo.user.vo.UserVO;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import jakarta.servlet.http.HttpSession;

@Controller
public class ChatController {

    private final ChatService chatService;
    private final ChatRedisService chatRedisService;
    private final MyPageService myPageService;

    @Autowired
    public ChatController(ChatService chatService, ChatRedisService chatRedisService, MyPageService myPageService) {
        this.chatService      = chatService;
        this.chatRedisService = chatRedisService;
        this.myPageService    = myPageService;
    }

    /** 채팅방 생성 or 기존 방 조회 → roomId 반환 (AJAX용) — 닉네임 없으면 차단 */
    @PostMapping("/member/chat/room/enter")
    @ResponseBody
    public ResponseEntity<String> enterChatRoom(@RequestParam int productId, @RequestParam int targetUserNo, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        long userNo = loginUser.getUserNo();
        if (!myPageService.hasNickname(userNo)) {
            return ResponseEntity.status(403).body("NICKNAME_REQUIRED");
        }
        ChatRoom room = chatService.getOrCreateRoom(productId, (int) userNo, targetUserNo);
        return ResponseEntity.ok(String.valueOf(room.getRoomId()));
    }

    /** 채팅방 화면 렌더링 (폼 submit용) */
    @PostMapping("/member/chat/room")
    public String chatRoom(@RequestParam int productId, @RequestParam int targetUserNo,
                           @RequestParam String roomId, Model model, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        long userNo = loginUser.getUserNo();

        // Redis 미읽음 초기화 (dirty 마킹 → 스케줄러가 DB 동기화)
        chatRedisService.resetUnread(roomId, (int) userNo);

        Map msgMap = new HashMap();
        msgMap.put("roomId", roomId);
        List<ChatMessage> messages = chatService.getChatMessagesOnly(msgMap);
        Map roomDetail = chatService.getChatRoomDetail(roomId, userNo);

        model.addAttribute("roomId", roomId);
        model.addAttribute("targetUserNo", targetUserNo);
        model.addAttribute("messages", messages);
        model.addAttribute("room", roomDetail);

        return "chat/chatroom";
    }

    @GetMapping("/member/chat/unread")
    @ResponseBody
    public int getUnreadCount(@RequestParam int roomId, @RequestParam int userNo) {
        return chatService.getUnreadMessageCount(roomId, userNo);
    }
    
    @GetMapping("/member/chat")
    public String chatList(@RequestParam(defaultValue = "1") int page,
                           HttpSession session, Model model) {
        long userNo = ((UserVO)session.getAttribute("loginUser")).getUserNo();
        PageHelper.startPage(page, 12);
        List<ChatRoom> rooms = chatService.getUserChatRooms(userNo);
        PageInfo<ChatRoom> pageInfo = new PageInfo<>(rooms);

        // Redis 값 우선 사용 (resetUnread로 0이 세팅된 경우 DB stale 값으로 덮어쓰지 않음)
        int total = 0;
        for (ChatRoom r : rooms) {
            int unread = chatRedisService.getEffectiveUnread(r.getRoomId(), (int) userNo, r.getUnreadCount());
            r.setUnreadCount(unread);
            total += unread;
        }
        chatRedisService.initTotalUnread((int) userNo, total);

        model.addAttribute("rooms", rooms);
        model.addAttribute("currentPage", pageInfo.getPageNum());
        model.addAttribute("totalPages",  pageInfo.getPages());
        return "chat/chatList";
    }

}
