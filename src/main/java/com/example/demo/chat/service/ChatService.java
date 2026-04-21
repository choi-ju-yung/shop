package com.example.demo.chat.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.chat.dao.ChatDao;
import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.chat.vo.ChatRoom;

@Service
@Transactional
public class ChatService {
    
    private final ChatDao chatDao;
    
    @Autowired
    public ChatService(ChatDao chatDao) {
    	this.chatDao = chatDao;
	}

    public void saveMessage(ChatMessage message) {
    	chatDao.saveMessage(message);
    }

    public ChatRoom getOrCreateRoom(int productId, int senderUserNo, int receiverUserNo) {
    	Map map = new HashMap();
    	map.put("productId", productId);
    	map.put("senderUserNo", senderUserNo);
    	map.put("receiverUserNo", receiverUserNo);
    	
        ChatRoom room = chatDao.findRoomByParticipants(map);
        
        if (room == null) {
            int result = chatDao.createRoom(map);
            room = chatDao.findRoomByParticipants(map);
        }
        return room;
    }

    public List<ChatMessage> getMessages(int roomId) {
        return chatDao.getMessages(roomId);
    }

    public void markMessagesAsRead(String roomId, int userNo) {
    	Map map = new HashMap();
    	map.put("roomId", roomId);
    	map.put("userNo", userNo);
    	
        chatDao.markMessagesAsRead(map);
    }

    public int getUnreadMessageCount(int roomId, int userNo) {
    	Map map = new HashMap();
    	map.put("roomId", roomId);
    	map.put("userNo", userNo);
    	
        return chatDao.getUnreadMessageCount(map);
    }
    
    public List<ChatRoom> getUserChatRooms(long userNo){
    	return chatDao.getUserChatRooms(userNo);
    }
    
    public int insertChatMessage(Map map) {
    	return chatDao.insertChatMessage(map);
    }
    
    public List<ChatMessage> getChatMessagesByRoomId(Map map){
    	chatDao.updateReadMessage(map);
    	return chatDao.getChatMessagesByRoomId(map);
    }
    
    public Map getLatestMessageNameTimeInfo(String roomId) {
    	return chatDao.getLatestMessageNameTimeInfo(roomId);
    }
    
    public List<ChatRoom> getSingleChatRoomInfo(Map map){
    	return chatDao.getSingleChatRoomInfo(map);
    }

    public int getTotalUnreadCount(long userNo) {
        return chatDao.getTotalUnreadCount(userNo);
    }

    public Map getChatRoomDetail(String roomId, long userNo) {
        Map map = new HashMap();
        map.put("roomId", roomId);
        map.put("userNo", userNo);
        return chatDao.getChatRoomDetail(map);
    }

    public List<Map> getChatBuyersByProductId(Long productId, long userNo) {
        Map map = new HashMap();
        map.put("productId", productId);
        map.put("userNo", userNo);
        return chatDao.getChatBuyersByProductId(map);
    }

}
