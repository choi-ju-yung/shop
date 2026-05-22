	package com.example.demo.config;

	import java.time.Duration;

	import org.springframework.cache.annotation.EnableCaching;
	import org.springframework.context.annotation.Bean;
	import org.springframework.context.annotation.Configuration;
	import org.springframework.data.redis.cache.RedisCacheConfiguration;
	import org.springframework.data.redis.cache.RedisCacheManager;
	import org.springframework.data.redis.connection.RedisConnectionFactory;
	import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
	import org.springframework.data.redis.serializer.RedisSerializationContext;
	import org.springframework.data.redis.serializer.RedisSerializer;

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
			return new GenericJackson2JsonRedisSerializer();
		}
	}
