package com.example.demo.regist.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.ui.Model;
import com.example.demo.regist.service.RegistService;
import com.example.demo.user.vo.UserVO;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/regist")
public class RegistController {

	private final RegistService registService;

	@Autowired
	public RegistController(RegistService registService) {
		this.registService = registService;
	}

	@PostMapping("/nomalInsert")
	public String nomalInsert(@ModelAttribute UserVO userVO, RedirectAttributes redirectAttributes) {
		try {
			registService.nomalInsert(userVO);
			redirectAttributes.addFlashAttribute("msg","회원가입이 완료되었습니다.");
			return "redirect:/login";
		} catch (RuntimeException e) {
			 redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
			 return "redirect:/regist/nomalregist";
		}
	}

	@GetMapping("/kakao")
	public String kakaoRegistForm(HttpSession session, Model model) {
		String oauthId = (String) session.getAttribute("kakaoOauthId");
		if (oauthId == null) {
			return "redirect:/login";
		}
		model.addAttribute("nickname", session.getAttribute("kakaoNickname"));
		model.addAttribute("oauthId", oauthId);
		model.addAttribute("email", session.getAttribute("kakaoEmail"));
		return "regist/kakaoregist";
	}

}
