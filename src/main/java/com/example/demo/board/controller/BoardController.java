package com.example.demo.board.controller;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.board.service.BoardService;
import com.example.demo.board.vo.Board;

import jakarta.servlet.http.HttpServletRequest;

@Controller
public class BoardController {

	private final BoardService boardService;

	@Autowired
	public BoardController(BoardService boardService) {
		this.boardService = boardService;
	}
	
	@RequestMapping("/checkTimeBoard")
	@ResponseBody
	public List<Board> checkTimeBoard(){
		System.out.println("실행");
		return boardService.getBoardList();
	}
	
	@RequestMapping("/checkTimeBoardByCategory")
	@ResponseBody
	public List<Board> checkTimeBoardByCategory(@RequestParam(value = "category", required = false) String category){
		if(category == null || category.trim().isEmpty()) {
			return boardService.getBoardList(); // 전체실행
		}else {
			return boardService.getBoardListByCategory(category); // 카테고리 조회
		}
	}
	

	@RequestMapping("/user/boardList")
	public String boardList(@RequestParam(defaultValue = "1") int cPage,
			@RequestParam(defaultValue = "N") String notice, Model model,
			@RequestParam(required = false) String category, HttpServletRequest request) throws UnsupportedEncodingException {

		int pageSize = 10;
		List<Board> boardList = boardService.getPagedBoardList(cPage, pageSize, notice, category);
		int totalData = boardService.getTotalBoardCount(notice, category);
		int totalPage = (int) Math.ceil((double) totalData / pageSize);

	    String url = request.getContextPath() + "/user/boardList";
	    StringBuilder queryString = new StringBuilder();
	    queryString.append("&notice=").append(notice);
	    if (category != null && !category.equals("전체")) {
	        queryString.append("&category=").append(URLEncoder.encode(category, StandardCharsets.UTF_8));
	    }
		
	    String pageBar = getPageBar(cPage, totalData, pageSize, url, queryString.toString());

		
		model.addAttribute("pageBar",pageBar);
		model.addAttribute("boardList", boardList);
		model.addAttribute("cPage", cPage);
		model.addAttribute("totalPage", totalPage);
		model.addAttribute("noticeYN", notice);
		model.addAttribute("category", category); // JSP에서 다시 넘기기용

		return "board/boardList";
	}
	
	
	public String getPageBar(int cPage, int totalData, int pageSize, String url, String queryString) {
	    int totalPage = (int) Math.ceil((double) totalData / pageSize);
	    int pageBarSize = 10;
	    int pageStart = ((cPage - 1) / pageBarSize) * pageBarSize + 1;
	    int pageEnd = pageStart + pageBarSize - 1;
	    pageEnd = Math.min(pageEnd, totalPage);

	    StringBuilder pageBar = new StringBuilder();

	    if (pageStart > 1) {
	        pageBar.append("<li><a href='").append(url).append("?cPage=1").append(queryString).append("'>처음</a></li>");
	        pageBar.append("<li><a href='").append(url).append("?cPage=").append(pageStart - 1).append(queryString).append("'>이전</a></li>");
	    }

	    for (int i = pageStart; i <= pageEnd; i++) {
	        if (i == cPage) {
	            pageBar.append("<li><span class='nowPage'>").append(i).append("</span></li>");
	        } else {
	            pageBar.append("<li><a href='").append(url).append("?cPage=").append(i).append(queryString).append("'>").append(i).append("</a></li>");
	        }
	    }

	    if (pageEnd < totalPage) {
	        pageBar.append("<li><a href='").append(url).append("?cPage=").append(pageEnd + 1).append(queryString).append("'>다음</a></li>");
	        pageBar.append("<li><a href='").append(url).append("?cPage=").append(totalPage).append(queryString).append("'>끝</a></li>");
	    }

	    return pageBar.toString();
	}
	
}
