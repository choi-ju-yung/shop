package com.example.demo.regist.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.ui.Model;
import com.example.demo.regist.service.RegistService;
import com.example.demo.user.vo.UserVO;

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
	public String kakaoRegistForm(@AuthenticationPrincipal OAuth2User oauthUser, Model model) {
		model.addAttribute("nickname", oauthUser.getAttribute("nickname"));
		model.addAttribute("oauthId", oauthUser.getAttribute("oauthId"));
		model.addAttribute("email", oauthUser.getAttribute("email"));

		return "regist/kakaoregist";
	}
}
