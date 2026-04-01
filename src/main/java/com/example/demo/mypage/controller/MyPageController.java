package com.example.demo.mypage.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.example.demo.mypage.service.MyPageService;
import com.example.demo.mypage.vo.MyPage;
import com.example.demo.user.service.UserService;
import com.example.demo.user.vo.UserVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
public class MyPageController {
	
	private final UserService userService;
	private final MyPageService myPageService;
	
	@Autowired
	public MyPageController(UserService userService, MyPageService myPageService) {
		this.userService = userService;
		this.myPageService = myPageService;
	}
	
	@GetMapping("/member/mypage")
	public String MyPageView(HttpServletRequest request, Model model) {
		HttpSession session = request.getSession();
		long userNo = ((UserVO)session.getAttribute("loginUser")).getUserNo();
		
		UserVO user = userService.findByUserNo(userNo);
		MyPage myPage = myPageService.findByMyPage(userNo);
		
		
		model.addAttribute("myPage",myPage);
		model.addAttribute("user",user);
		
		return "mypage/myPageMain";
	}
}
