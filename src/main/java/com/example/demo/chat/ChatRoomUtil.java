package com.example.demo.chat;

import java.util.Arrays;
import java.util.List;

import edu.emory.mathcs.backport.java.util.Collections;

public class ChatRoomUtil {
    public static String createRoomId(String userA, String userB) {
        List<String> users = Arrays.asList(userA, userB);
        Collections.sort(users);
        return users.get(0) + "_" + users.get(1);
    }
}