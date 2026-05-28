package com.example.demo.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${app.upload.dir:C:/upload}")
    private String uploadDir;
    
    // 브라우저가 /upload/xxx 요청하면 → 서버의 C:/upload/xxx 파일을 찾아서 반환
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String resourceLocation = "file:///" + uploadDir.replace("\\", "/") + "/";
        registry.addResourceHandler("/upload/**")
                .addResourceLocations(resourceLocation)
                .setCachePeriod(3600);
    }
}
