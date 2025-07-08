package com.example.demo.notification;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Notification {
    private String notiId;
    private int userNo;
    private String notiMessage;
    private String notiUrl;
    private String isRead;
    private Timestamp createdAt;
    private String notificationType;
    
}
