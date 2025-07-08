<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ include file="../common/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!-- 게시글 스타일 적용 -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/customcenter/boardList.css">
<%-- <%
	List<Board> boardList=(List)request.getAttribute("boardList"); //게시판 리스트
	char notice=((String)request.getAttribute("noticeYN")).charAt(0);
%> --%>
<section>
	<%-- <%@ include file="/views/service/serviceCategory.jsp" %> --%>
	<div class="ServiceCenter">
      <h2 class="ServicetHead">
      	${noticeYN eq 'N' ? '공지사항' : '자주하는 질문'}
      	<%-- <% if(loginMember!=null&&loginMember.getAuth().equals("M")){ %> --%>
	      <button class="contentBtn" onclick="location.href='<%=request.getContextPath()%>/service/boardInsert.do'">글 작성</button>
	     <%--  <% } %> --%>
      </h2>
      <%-- <% if(notice=='N'){ %>
      	<div class="QACategory">
      		<button class="QABtn">전체</button>
          <button class="QABtn">회원정보</button>
          <button class="QABtn">구매</button>
          <button class="QABtn">판매</button>
          <button class="QABtn">기타</button>
        </div>
      <% } %> --%>
		<div class="boardContainer">
			<table>
				<c:choose>
					<c:when test="${not empty boardList}">
						<c:forEach var="b" items="${boardList}">
							<c:choose>
								<c:when test="${noticeYN eq 'Y'}">
									<tr onclick="location.href='${pageContext.request.contextPath}/service/boardContent.do?boardNo=${b.boardNo}'">
										<td>${b.boardNo}</td>
										<td class="noticeTitle">${b.boardTitle}</td>
										<td>${b.boardDate}</td>
									</tr>
								</c:when>
								<c:otherwise>
									<tr onclick="location.href='${pageContext.request.contextPath}/service/boardContent.do?boardNo=${b.boardNo}'">
										<td>${b.boardNo}</td>
										<td class="QATitle">[${b.boardCategory}] ${b.boardTitle}</td>
									</tr>
								</c:otherwise>
							</c:choose>
							<tr class="tableLine"><td colspan="3"></td></tr>
						</c:forEach>
					</c:when>
					<c:otherwise>
						<tr><td colspan="3">조회된 데이터가 없습니다.</td></tr>
					</c:otherwise>
				</c:choose>
			</table>

			<!-- 페이징 바 -->
			<div class="pageBar">
				<ul class="page">
					<c:out value="${pageBar}" escapeXml="false"/>
				</ul>
	    </div>
      </div>
    </div>
</section>
<script>
	$(".QABtn").click(e=>{
		const category=$(e.target).text();
		$(location).attr('href',"<%=request.getContextPath()%>/service/boardListCategory.do?data="+category);
	});
</script>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/page.css">
<%@ include file="../common/footer.jsp" %>