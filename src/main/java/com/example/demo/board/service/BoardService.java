package com.example.demo.board.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import com.example.demo.board.dao.BoardDao;
import com.example.demo.board.vo.Board;

@Service
public class BoardService {
	
	private final BoardDao boardDao;
	
	public BoardService(BoardDao boardDao) {
		this.boardDao = boardDao;
	}
	
	public List<Board> getPagedBoardList(int offset, int limit, String notice, String category) {

	    Map<String,Object> param = new HashMap<>();
	    param.put("offset", offset);
	    param.put("limit", limit);
	    param.put("notice", notice);
	    param.put("category", category);
	    
	    return boardDao.getPagedBoardList(param);
	}

	public int getTotalBoardCount(String notice, String category) {
		Map<String, Object> param = new HashMap<>();
	    param.put("notice", notice);
	    param.put("category", category);
	    return boardDao.getTotalBoardCount(param);
	}
	
	@Cacheable(value = "boardList",key = "'allBoards'") // api로 redis 전체 데이터 호출 테스트
	public List<Board> getBoardList(){
		System.out.println("db안거침");
		return boardDao.getBoardList();
	}
	
	@Cacheable(value = "boardList", key = "'category:' + #category") // api로 redis 검색 데이터 호출 테스트
	public List<Board> getBoardListByCategory(String category) {
		System.out.println("db안거침");
	    return boardDao.getBoardListByCategory(category);
	}
}
