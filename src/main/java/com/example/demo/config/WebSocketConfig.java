package com.example.demo.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

import com.example.demo.CustomHandshakeHandler;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer{
	
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws").setAllowedOriginPatterns("*").setHandshakeHandler(new CustomHandshakeHandler()).withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {	
    	registry.setApplicationDestinationPrefixes("/app");
    	registry.enableSimpleBroker("/topic","/queue"); // 브로커가 처리해야할 경로
    	registry.setUserDestinationPrefix("/user"); // 특정 사용자에게 메시지 전송시 사용할 주소
    }
    
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**")
                    .allowedOriginPatterns("*") // allowedOrigins("*")로 하면 에러
                    .allowedMethods("*")
                    .allowCredentials(true);
            }
        };
    }
}
