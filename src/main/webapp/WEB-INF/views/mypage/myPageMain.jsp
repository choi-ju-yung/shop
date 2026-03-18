<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="../common/header.jsp"%>
<%@ include file="../mypage/myPageCategory.jsp"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%-- <%@ page import="com.semi.mypage.model.vo.MemberShopPage" %> --%>
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/css/mypage/myPageMain.css" />
<%-- <%
	MemberShopPage mypageMember = (MemberShopPage)request.getAttribute("mypageMember");
	int countTrade = (int)request.getAttribute("countTrade");
%> --%>
<!-- section -->

<!-- 오른쪽 section -->
<div class="myPageMainAll">
	<div class="profileMain">
		<div class="profileInfo">
			<img src="/css/images/profile/${profileImg}" alt=""
				style="width: 130px; height: 130px; border-radius: 300px; margin-left: 90px; border: #f2f2f2 1px solid;">
			<div class="nameNdate">
				<div class="profileName">
					<h1>${user.username}님</h1>
					<c:choose>
						<c:when test="${myPage.temperature <= 50}">
							<div class="temperature">
								<h4>${myPage.temperature}℃</h4>
							</div>
						</c:when>
						<c:when test="${myPage.temperature <= 75}">
							<div class="temperature orangeTem">
								<h4>${myPage.temperature}℃</h4>
							</div>
						</c:when>
						<c:otherwise>
							<div class="temperature remTem">
								<h4>${myPage.temperature}℃</h4>
							</div>
						</c:otherwise>
					</c:choose>


				</div>
				<div class="enrollDate">
					<h4>가입일</h4>
					<span> <%-- <%=mypageMember.getMember().getEnrollDate() %> --%>
					</span>
				</div>
			</div>
		</div>
		<div class="countTrade">
			<h3>성사된 거래</h3>
			<div class="countTradeInfo">
				<span> <%-- <%=countTrade %> --%>
				</span>
				<h4>건</h4>
			</div>
		</div>
	</div>
	<div class="notificationMain">
		<h3>알림</h3>
		<hr width="1050px" color="#313030" noshade style="margin-top: 15px;" />
		<div class="notificationAll">
			<div class="notification">
				<a href=""><span>‘상품명을 작성해주세요.’ 글에 새 댓글이 등록되었습니다.</span></a> <span
					class="notiDate">2023.05.11 AM 02 : 30</span>
			</div>
			<hr width="1050px" color="#eee" />
			<div class="notification">
				<a href=""><span>‘연락주세요’ 댓글에 새 댓글이 등록되었습니다.</span></a> <span
					class="notiDate">2023.05.11 AM 02 : 30</span>
			</div>
			<hr width="1050px" color="#eee" />
			<div class="notification">
				<a href=""><span>관심상품 ‘상품명을 작성해주세요.’ 정보가 수정되었습니다.</span></a> <span
					class="notiDate">2023.05.11 AM 02 : 30</span>
			</div>
			<hr width="1050px" color="#eee" />
			<div class="notification">
				<a href="" class="notiRead"><span>‘상품명을 작성해주세요.’ 글에 새 댓글이
						등록되었습니다.</span></a> <span class="notiDate">2023.05.11 AM 02 : 30</span>
			</div>
			<hr width="1050px" color="#eee" />
			<div class="notification">
				<a href="" class="notiRead"><span>‘상품명을 작성해주세요.’ 글에 새 댓글이
						등록되었습니다.</span></a> <span class="notiDate">2023.05.11 AM 02 : 30</span>
			</div>
		</div>
		<hr width="1050px" color="#313030" noshade
			style="margin-bottom: 50px;" />
	</div>

</div>
</section>
<%@ include file="../common/footer.jsp"%>