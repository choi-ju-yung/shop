package com.example.demo.board.vo;

import java.io.Serializable;
import java.sql.Date;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Builder
public class Board implements Serializable{
	private static final long serialVersionUID = 1L;
	private int boardNo;
	private String boardWriter;
	private String boardTitle;
	private String boardContent;
	private Date boardDate;
	private String boardCategory;
	private String noticeYn;
	private String boardOriginalFileName;
	private String boardRenamedFileName;
	private int rnum; // rownum 추가 필요
}
