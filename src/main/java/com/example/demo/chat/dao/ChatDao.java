package com.example.demo.chat.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.example.demo.chat.vo.ChatMessage;
import com.example.demo.chat.vo.ChatRoom;

@Repository 
public class ChatDao {
	
	private final SqlSession session;
	
	@Autowired
	public ChatDao(SqlSession session) {
		this.session = session;
	}
	
    public void saveMessage(ChatMessage message) {
    	session.insert("ChatMapper.insertMessage",message);
    }

    public List<ChatMessage> selectMessagesByRoomId(String roomId) {
        return session.selectList("ChatMapper.selectMessagesByRoomId",roomId); 
    }
    
   public ChatRoom findRoomByParticipants(Map map) {
	   return session.selectOne("ChatMapper.findRoomByParticipants",map);
   }
   
   public int createRoom(Map map) {
	   return session.insert("ChatMapper.createRoom",map);
   }
   
   public List<ChatMessage> getMessages(int roomId){
	   return session.selectList("ChatMapper.getMessages",roomId);
   }
   
   public int markMessagesAsRead(Map map) {
	   return session.update("ChatMapper.markMessagesAsRead",map);
   }
   
   public int getUnreadMessageCount(Map map) {
	   return session.selectOne("ChatMapper.getUnreadMessageCount",map);
   }
	
   public List<ChatRoom> getUserChatRooms(long userNo){
	   return session.selectList("ChatMapper.getUserChatRooms",userNo);
   }
   
   public int insertChatMessage(Map map) {
	   return session.insert("ChatMapper.insertChatMessage",map);
   }
   
   public List<ChatMessage> getChatMessagesByRoomId(Map map){
	   return session.selectList("ChatMapper.getChatMessagesByRoomId",map);
   }
   
   public int updateReadMessage(Map map) {
	   return session.update("ChatMapper.updateReadMessage",map);
   }
   
   public Map getLatestMessageNameTimeInfo(String roomId) {
	   return session.selectOne("ChatMapper.getLatestMessageNameTimeInfo",roomId);
   }
   
   public List<ChatRoom> getSingleChatRoomInfo(Map map){
	   return session.selectList("ChatMapper.getSingleChatRoomInfo",map);
   }

   public int getTotalUnreadCount(long userNo) {
	   return session.selectOne("ChatMapper.getTotalUnreadCount", userNo);
   }

   public Map getChatRoomDetail(Map map) {
	   return session.selectOne("ChatMapper.getChatRoomDetail", map);
   }

   public List<Map> getChatBuyersByProductId(Map map) {
	   return session.selectList("ChatMapper.getChatBuyersByProductId", map);
   }

}
