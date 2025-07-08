package com.example.demo.board.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import com.example.demo.board.vo.Board;

@Repository
public class BoardDao {
	
	private final SqlSession session;
	
	public BoardDao(SqlSession session) {
		this.session = session;
	}
	
	public List<Board> getPagedBoardList(Map<String, Object> param) {
		return session.selectList("CustomCenter.getPagedBoardList",param);
	}
	
	public int getTotalBoardCount(Map param) {
		return session.selectOne("CustomCenter.getTotalBoardCount",param);
	}
	
	public List<Board> getBoardList(){
		return session.selectList("CustomCenter.getBoardList");
	}
	
	public List<Board> getBoardListByCategory(String category){
		return session.selectList("CustomCenter.getBoardListByCategory",category);
	}
	
}
