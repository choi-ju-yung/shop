	package com.example.demo.config;

	import java.time.Duration;

	import com.fasterxml.jackson.annotation.JsonAutoDetect;
	import com.fasterxml.jackson.annotation.JsonTypeInfo;
	import com.fasterxml.jackson.annotation.PropertyAccessor;
	import com.fasterxml.jackson.databind.ObjectMapper;
	import com.fasterxml.jackson.databind.jsontype.impl.LaissezFaireSubTypeValidator;
	import org.springframework.cache.annotation.EnableCaching;
	import org.springframework.context.annotation.Bean;
	import org.springframework.context.annotation.Configuration;
	import org.springframework.data.redis.cache.RedisCacheConfiguration;
	import org.springframework.data.redis.cache.RedisCacheManager;
	import org.springframework.data.redis.connection.RedisConnectionFactory;
	import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
	import org.springframework.data.redis.serializer.RedisSerializationContext;
	import org.springframework.data.redis.serializer.RedisSerializer;
	import org.springframework.security.jackson2.SecurityJackson2Modules;
	import org.springframework.security.oauth2.client.jackson2.OAuth2ClientJackson2Module;

	@Configuration
	@EnableCaching
	public class RedisConfig {

		@Bean
		public RedisCacheManager cacheManager(RedisConnectionFactory connectionFactory) {
			RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
					.serializeValuesWith(RedisSerializationContext.SerializationPair
							.fromSerializer(new GenericJackson2JsonRedisSerializer()))
					.entryTtl(Duration.ofMinutes(10))
					.disableCachingNullValues();

			return RedisCacheManager.builder(connectionFactory).cacheDefaults(config).build();
		}

		@Bean("springSessionDefaultRedisSerializer")
		public RedisSerializer<Object> springSessionDefaultRedisSerializer() {
			ObjectMapper mapper = new ObjectMapper();
			mapper.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
			mapper.activateDefaultTyping(
				LaissezFaireSubTypeValidator.instance,
				ObjectMapper.DefaultTyping.NON_FINAL,
				JsonTypeInfo.As.PROPERTY
			);
			mapper.registerModules(SecurityJackson2Modules.getModules(getClass().getClassLoader()));
			mapper.registerModule(new OAuth2ClientJackson2Module());
			return new GenericJackson2JsonRedisSerializer(mapper);
		}
	}
