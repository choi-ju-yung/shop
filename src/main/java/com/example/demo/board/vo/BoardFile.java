package com.example.demo.board.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Builder
public class BoardFile {
	private int boardNo;
	private int fileNo;
	private String boardFileName;
}
