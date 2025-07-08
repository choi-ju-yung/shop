package com.example.demo.chat.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.chat.service.ChatService;
import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.chat.vo.ChatRoom;
import com.example.demo.user.vo.UserVO;

import jakarta.servlet.http.HttpSession;

@Controller
public class ChatController {
	
    private final ChatService chatService;
    
    @Autowired
    public ChatController(ChatService chatService) {
    	this.chatService = chatService;
	}

    @PostMapping("/room")
    public String chatRoom(@RequestParam int productId, @RequestParam int targetUserNo, @RequestParam String roomId,Model model) {
        model.addAttribute("productId", productId);
        model.addAttribute("targetUserNo", targetUserNo);
        model.addAttribute("roomId",roomId);
        
        Map map = new HashMap();
        map.put("roomId", roomId);
        map.put("targetUserNo", targetUserNo);
        
        List<ChatMessage> messages = chatService.getChatMessagesByRoomId(map);
       
        model.addAttribute("messages",messages);
        
        return "chat/chatroom";
    }

    @GetMapping("/notifications")
    @ResponseBody
    public int getUnreadCount(@RequestParam int roomId, @RequestParam int userNo) {
        return chatService.getUnreadMessageCount(roomId, userNo);
    }
    
    @GetMapping("/chatList")
    public String chatList(HttpSession session, Model model) {
    	long userNo = ((UserVO)session.getAttribute("loginUser")).getUserNo();

        List<ChatRoom> rooms = chatService.getUserChatRooms(userNo);
        model.addAttribute("rooms", rooms);
        return "chat/chatList";
    }

}
