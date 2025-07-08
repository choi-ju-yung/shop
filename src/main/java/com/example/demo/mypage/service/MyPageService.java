package com.example.demo.mypage.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.mypage.dao.MyPageDao;
import com.example.demo.mypage.vo.MyPage;

@Service
public class MyPageService {
	
	private final MyPageDao myPageDao;
	
	@Autowired
	public MyPageService(MyPageDao myPageDao) {
		this.myPageDao = myPageDao;
	}
	
	public MyPage findByMyPage(long userNo) {
		return myPageDao.findByMyPage(userNo);
	}
	
}
