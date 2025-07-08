package com.example.demo.mypage.dao;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.example.demo.mypage.vo.MyPage;

@Repository
public class MyPageDao {
	
	private final SqlSession sqlSession;
	
	@Autowired
	public MyPageDao(SqlSession sqlSession) {
		this.sqlSession = sqlSession;
	}
	
	public MyPage findByMyPage(long userNo) {
		return sqlSession.selectOne("MyPageMapper.findByMyPage",userNo);
	}
	
	public int registUserPage(long userId) {
		return sqlSession.insert("MyPageMapper.registUserPage",userId);
	}
	
}
