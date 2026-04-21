<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/user/findname.css"/>

<div class="loginSection">
  <div class="authCard">

    <div class="authBrand">
      <img src="<%=request.getContextPath()%>/images/common/logo.svg" alt="니꺼내꺼" class="brandLogoImg">
      <h2>아이디 찾기</h2>
      <p>가입 시 등록한 이름과 이메일을 입력하세요</p>
    </div>

    <div class="authResultBox" id="resultBox"></div>

    <div class="authFields">
      <input class="authInput" type="text" id="findName" placeholder="이름">
      <input class="authInput" type="email" id="findEmail" placeholder="이메일 주소">
    </div>

    <button class="authBtn" onclick="findId()">아이디 찾기</button>

    <div class="authLinks">
      <a href="<%=request.getContextPath()%>/login">로그인</a>
      <a href="<%=request.getContextPath()%>/find/pwd">비밀번호 찾기</a>
      <a href="<%=request.getContextPath()%>/regist/nomalregist">회원가입</a>
    </div>

  </div>
</div>

<script>
function findId() {
  var name  = document.getElementById('findName').value.trim();
  var email = document.getElementById('findEmail').value.trim();
  var box   = document.getElementById('resultBox');

  if (!name || !email) {
    box.className = 'authResultBox error';
    box.style.display = 'block';
    box.textContent = '이름과 이메일을 모두 입력해주세요.';
    return;
  }

  $.ajax({
    url: '<%=request.getContextPath()%>/find/id',
    method: 'POST',
    data: { name: name, email: email },
    success: function(res) {
      box.style.display = 'block';
      if (res.found) {
        box.className = 'authResultBox';
        box.innerHTML = '회원님의 아이디는 <strong>' + res.loginId + '</strong> 입니다.';
      } else {
        box.className = 'authResultBox error';
        box.textContent = '일치하는 회원 정보를 찾을 수 없습니다.';
      }
    },
    error: function() {
      box.className = 'authResultBox error';
      box.style.display = 'block';
      box.textContent = '처리 중 오류가 발생했습니다. 다시 시도해주세요.';
    }
  });
}

document.addEventListener('keydown', function(e) {
  if (e.key === 'Enter') findId();
});
</script>

<%@ include file="../common/footer.jsp"%>
