package com.example.demo.notification;

import java.util.List;
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

	public int updateUnreadNotification(Map<String, Object> map) {
		return notiDao.updateUnreadNotification(map);
	}

	public int selectNoReadNotiByN(int userNo) {
		return notiDao.selectNoReadNotiByN(userNo);
	}
	
	public int selectNoReadNotiByNFromM(int userNo) {
		return notiDao.selectNoReadNotiByNFromM(userNo);
	}

	public int markAllAsRead(long userNo) {
		return notiDao.markAllAsRead(userNo);
	}

	public List<Notification> selectNotifications(long userNo) {
		return notiDao.selectNotifications(userNo);
	}
}
