package com.example.demo.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;

@Configuration
public class WebConfig {
	
	public void addResourceHandlers(ResourceHandlerRegistry registry) {
	    registry.addResourceHandler("/upload/**") // 요청 URL 패턴을 정의
	            .addResourceLocations("file:///C:/upload/") // 실제 리소스가 저장된 물리적 경로를 지정
	            .setCachePeriod(3600); // 캐싱 기간 설정 (초 단위) 
	}
}
