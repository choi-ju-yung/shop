package com.example.demo.regist.dao;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import com.example.demo.user.vo.UserVO;

@Repository
public class RegistDao {
	private final SqlSession sqlSession;
	
	public RegistDao(SqlSession sqlSession) {
		this.sqlSession = sqlSession;
	}
	
	public int nomalInsert(UserVO userVO) {
		return sqlSession.insert("RegistUserMapper.nomalInsert",userVO);
	}
	
	public int nomalInsertUserPage(com.example.demo.user.vo.UserVO userVO) {
		return sqlSession.insert("RegistUserMapper.nomalInsertUserPage", userVO);
	}
}
