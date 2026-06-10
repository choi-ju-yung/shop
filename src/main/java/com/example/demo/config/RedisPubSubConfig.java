package com.example.demo.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.listener.ChannelTopic;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;
import org.springframework.data.redis.listener.adapter.MessageListenerAdapter;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import com.example.demo.chat.redis.RedisSubscriber;

@Configuration
public class RedisPubSubConfig {

    public static final String CHAT_CHANNEL          = "chat-channel";
    public static final String READ_RECEIPT_CHANNEL  = "read-receipt-channel";

    @Bean
    public RedisTemplate<String, String> chatRedisTemplate(RedisConnectionFactory factory) {
        RedisTemplate<String, String> template = new RedisTemplate<>();
        template.setConnectionFactory(factory);
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new StringRedisSerializer());
        return template;
    }

    @Bean
    public MessageListenerAdapter messageListenerAdapter(RedisSubscriber redisSubscriber) {
        return new MessageListenerAdapter(redisSubscriber, "onChatMessage");
    }

    @Bean
    public MessageListenerAdapter readReceiptListenerAdapter(RedisSubscriber redisSubscriber) {
        return new MessageListenerAdapter(redisSubscriber, "onReadReceipt");
    }

    @Bean
    public RedisMessageListenerContainer redisMessageListenerContainer(
            RedisConnectionFactory factory,
            MessageListenerAdapter listenerAdapter,
            MessageListenerAdapter readReceiptListenerAdapter) {
        RedisMessageListenerContainer container = new RedisMessageListenerContainer();
        container.setConnectionFactory(factory);
        container.addMessageListener(listenerAdapter,            new ChannelTopic(CHAT_CHANNEL));
        container.addMessageListener(readReceiptListenerAdapter, new ChannelTopic(READ_RECEIPT_CHANNEL));
        return container;
    }
}
