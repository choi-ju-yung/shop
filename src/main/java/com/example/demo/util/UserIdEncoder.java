package com.example.demo.util;

/**
 * 사용자 ID를 URL에 노출하지 않기 위한 인코더/디코더
 * XOR + Base36 방식으로 숫자 ID를 문자열로 변환
 * 예) 37 → "1k6ogz8", 38 → "1k6ogza"
 */
public class UserIdEncoder {

    private static final long SECRET = 0x5F3759DFL;

    public static String encode(long id) {
        return Long.toString(id ^ SECRET, 36);
    }

    public static long decode(String encoded) {
        try {
            return Long.parseLong(encoded, 36) ^ SECRET;
        } catch (NumberFormatException e) {
            return -1L;
        }
    }
}
