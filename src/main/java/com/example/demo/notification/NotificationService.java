package com.example.demo.notification;

import java.util.Map;

import org.springframework.stereotype.Service;

@Service
public class NotificationService {
	
	private final NotificationDao notiDao;
	
	public NotificationService(NotificationDao notiDao) {
		this.notiDao = notiDao;
	}
	
	public void insertNotification(Map<String, Object> map) {
		notiDao.insertNotification(map);
	}
	
	public int selectNoReadNotiByN(int userNo) {
		return notiDao.selectNoReadNotiByN(userNo);
	}
	
	public int selectNoReadNotiByNFromM(int userNo) {
		return notiDao.selectNoReadNotiByNFromM(userNo);
	}
}
