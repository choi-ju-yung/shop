package com.example.demo.productregist.controller;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.UUID;
import java.util.Locale.Category;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.product.vo.Product;
import com.example.demo.product.vo.ProductFile;
import com.example.demo.productregist.service.ProductRegistService;
import com.example.demo.user.vo.UserVO;

import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/user")
public class ProductRegistController {

	private final ProductRegistService productRegistService;

	@Autowired
	public ProductRegistController(ProductRegistService productRegistService) {
		this.productRegistService = productRegistService;
	}

	/**
	 * 상품등록 화면으로 이동
	 */
	@GetMapping("/productRegist")
	public String productRegistView(Model model) {
		List<Category> categorys = productRegistService.selectAll();
		model.addAttribute("categorys", categorys);
		return "product/productregist";
	}

	@GetMapping("/findSubCate")
	@ResponseBody
	public String findSubCate(HttpServletRequest request) {
		String categoryName = request.getParameter("categoryName");
		List<String> subCategorys = productRegistService.findSubCate(categoryName);

		String result = subCategorys.stream().map(n -> String.valueOf(n)).collect(Collectors.joining(","));
		return result;
	}

	@PostMapping("/productRegistEnd")
	@ResponseBody // 뷰로 리턴이 아닌 문자열 값 자체를 리턴
	public String productRegistEnd(HttpServletRequest request, HttpSession session, 
			@RequestParam("title") String title,
			@RequestParam("subCate") String subCate,
			@RequestParam("place") String place,
			@RequestParam("state") String state,
			@RequestParam("price") String price,
			@RequestParam("explanation") String explanation,
			@RequestParam("tag") String tag,
			@RequestParam("mainImageIndex") int mainImageIndex,
		    @RequestParam("files") List<MultipartFile> files) {
		
		// 여기서 세션분기 로직으로 loginID인지 카카오 고유 ID인지 구별해야함 
		long userNo = ((UserVO)session.getAttribute("loginUser")).getUserNo();
		
		
		//String path= request.getServletContext().getRealPath("/upload/productRegist");  // ->  /upload/productRegist 안에다 업로드되는 이미지 넣음
		 String uploadDir = "C:/upload/productRegist"; // 절대 경로, 미리 생성되어 있어야 함
		
		File dir = new File(uploadDir);
		if(!dir.exists()) {
			dir.mkdirs(); // 디렉토리 생성
		}
		
		List<ProductFile> fileList= new ArrayList();
		
		for(int i=0; i<	files.size(); i++) {
			MultipartFile file = files.get(i);
			if(!file.isEmpty()) {
				try {
					 String originalFilename = file.getOriginalFilename(); // 나중에 사용자에게 보여줄 때 필요
		             String ext = originalFilename.substring(originalFilename.lastIndexOf(".")); // MIME 타입을 확인하거나, 이미지 리사이징/처리할 때 사용
		             String savedName = UUID.randomUUID().toString() + ext; // 중복 방지를 위해 반드시 필요 (UUID로 생성)
		             
		             File dest = new File(uploadDir, savedName);
		             file.transferTo(dest); // 실제파일저장
		             
		             fileList.add(ProductFile.builder()
		            		 .originalName(originalFilename)
		            		 .savedName(savedName)
		            		 .filePath("/upload/productRegist/"+savedName)
		            		 .isMain(i == mainImageIndex) // 대표 이미지인지 체크
		            		 .build());
				}catch(IOException e) {
					e.printStackTrace();
				}
			}
		}
		
		int realPrice = Integer.parseInt(price.replace(",", "")); // 쉼표있는 숫자를 정수로 바꾸는 과정
		
		
		 Product p = Product.builder().userNo(userNo).title(title).state(state).price(realPrice).explanation(explanation)
				 .tag(tag).place(place).subCate(subCate).productFiles(fileList).build();
		 
		int result = productRegistService.insertProduct(p); // 상품등록 및 상품이미지첨부파일 데이터 추가 하는 작업
	    return "1";
	}
}
