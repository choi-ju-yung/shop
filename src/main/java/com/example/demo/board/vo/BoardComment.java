package com.example.demo.board.vo;

import java.sql.Date;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
@Builder
public class BoardComment {
	private int commentNo;
	private String commentWriter;
	private int boardNo;
	private int commentNoFK;
	private Date commentDate;
	private String commentContent;
}
