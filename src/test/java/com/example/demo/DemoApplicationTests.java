package com.example.demo;

import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

class DemoApplicationTests {

	@Test
	void printBcryptHash() {
		BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
		System.out.println("hifive1234 hash: " + encoder.encode("hifive1234"));
		System.out.println("1234 hash: " + encoder.encode("1234"));
		
	}

}
