

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/css/user/findname.css" />
	
	<c:if test="${not empty msg}">
	<script>
		alert("${msg}");
	</script>
	</c:if>
	
<div class="loginSection">
	<section class="login">

		<form id="loginfrm"
			action="${pageContext.request.contextPath}/processLogin"
			method="post" onsubmit="return fn_validation()">
			<h2>로그인</h2>
			<ul>
				<li><input type="text" id="loginUserId" name="loginId"
					placeholder="아이디" title="아이디입력"></li>
				<li><input type="password" name="password" placeholder="비밀번호"
					title="비밀번호입력"></li>
				<!-- <li><input type="submit" value="로그인"></li> -->
				<li><button>로그인</button></li>
			</ul>
		</form>

		<a
			href="/oauth2/authorization/kakao">
			<img src="/images/common/kakaoImage.png" style="width: 400px"
			height="50px" alt="카카오톡 이미지" />
		</a>
		<div>
			<ul>
				<li><a href="<%=request.getContextPath()%>/regist/nomalregist">회원가입</a></li>
				<li><a href="<%=request.getContextPath()%>/findIdView.do">아이디찾기</a></li>
				<li><a href="<%=request.getContextPath()%>/findPwdView.do">비밀번호찾기</a></li>
			</ul>
		</div>
	</section>
</div>

<!-- 🔔 로그인 실패 시 alert 창 띄우기 -->
<c:if test="${param.error == 'true'}">
    <script type="text/javascript">
        alert("${param.message}");
    </script>
</c:if>



<script>

			const fn_validation=()=>{
				const userId=$("#loginUserId").val();
				if(userId.length<4){
					alert("아이디는 4글자 이상입니다.");
					$("#userId").val("");  // 문구띄어주고 아이디 빈칸으로바꾸고
					$("#userId").focus(); // 아이디부분에 포커스줌
			
					return false; // false면 값이 넘어가지 않음
				}
			}
</script>

<%@ include file="../common/footer.jsp"%>