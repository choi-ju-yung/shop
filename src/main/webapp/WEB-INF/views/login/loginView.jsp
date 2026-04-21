<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/user/findname.css"/>

<div class="loginSection">
  <div class="authCard">

    <div class="authBrand">
      <img src="<%=request.getContextPath()%>/images/common/logo.svg" alt="니꺼내꺼" class="brandLogoImg">
      <h2>로그인</h2>
      <p>안전한 중고거래를 시작하세요</p>
    </div>

    <c:if test="${not empty msg}">
      <div class="authResultBox" style="display:block;">${msg}</div>
    </c:if>

    <form id="loginfrm" action="${pageContext.request.contextPath}/processLogin"
          method="post" onsubmit="return fn_validation()">
      <div class="authFields">
        <input class="authInput" type="text" id="loginUserId" name="loginId"
               placeholder="아이디" autocomplete="username">
        <input class="authInput" type="password" name="password"
               placeholder="비밀번호" autocomplete="current-password">
      </div>
      <button type="submit" class="authBtn">로그인</button>
    </form>

    <div class="authDivider">또는</div>

    <a href="/oauth2/authorization/kakao" class="kakaoBtn">
      <img src="<%=request.getContextPath()%>/images/common/kakaoImage.png"
           onerror="this.style.display='none'" alt="">
      카카오로 시작하기
    </a>

    <div class="authLinks">
      <a href="<%=request.getContextPath()%>/regist/nomalregist">회원가입</a>
      <a href="<%=request.getContextPath()%>/find/id">아이디 찾기</a>
      <a href="<%=request.getContextPath()%>/find/pwd">비밀번호 찾기</a>
    </div>

  </div>
</div>

<c:if test="${param.error == 'true'}">
  <script>alert("${param.message}");</script>
</c:if>

<script>
function fn_validation() {
  var userId = document.getElementById('loginUserId').value;
  if (userId.length < 4) {
    alert('아이디는 4글자 이상입니다.');
    return false;
  }
  return true;
}
</script>

<%@ include file="../common/footer.jsp"%>
