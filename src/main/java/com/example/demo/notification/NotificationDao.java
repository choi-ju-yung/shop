package com.example.demo.notification;

import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class NotificationDao {
	
	private final SqlSession session;
	
	public NotificationDao(SqlSession session) {
		this.session = session;
	}
	
	public int insertNotification(Map<String, Object> map) {
		return session.insert("NotificationMapper.insertNotification",map);
	}
	
	public int selectNoReadNotiByN(int userNo) {
		return session.selectOne("NotificationMapper.selectNoReadNotiByN",userNo);
	}
	
	public int selectNoReadNotiByNFromM(int userNo) {
		return session.selectOne("NotificationMapper.selectNoReadNotiByNFromM",userNo);
	}
}
