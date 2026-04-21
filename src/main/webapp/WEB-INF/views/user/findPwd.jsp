<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/user/findname.css"/>

<div class="loginSection">
  <div class="authCard">

    <div class="authBrand">
      <img src="<%=request.getContextPath()%>/images/common/logo.svg" alt="니꺼내꺼" class="brandLogoImg">
      <h2>비밀번호 찾기</h2>
      <p>가입한 이메일로 임시 비밀번호를 전송합니다</p>
    </div>

    <div class="authResultBox" id="resultBox"></div>

    <div class="authFields">
      <input class="authInput" type="text" id="findLoginId" placeholder="아이디">
      <input class="authInput" type="email" id="findEmail" placeholder="가입한 이메일 주소">
    </div>

    <button class="authBtn" id="sendBtn" onclick="findPwd()">임시 비밀번호 전송</button>

    <div class="authLinks">
      <a href="<%=request.getContextPath()%>/login">로그인</a>
      <a href="<%=request.getContextPath()%>/find/id">아이디 찾기</a>
      <a href="<%=request.getContextPath()%>/regist/nomalregist">회원가입</a>
    </div>

  </div>
</div>

<script>
function findPwd() {
  var loginId = document.getElementById('findLoginId').value.trim();
  var email   = document.getElementById('findEmail').value.trim();
  var box     = document.getElementById('resultBox');
  var btn     = document.getElementById('sendBtn');

  if (!loginId || !email) {
    box.className = 'authResultBox error';
    box.style.display = 'block';
    box.textContent = '아이디와 이메일을 모두 입력해주세요.';
    return;
  }

  btn.disabled = true;
  btn.textContent = '전송 중...';

  $.ajax({
    url: '<%=request.getContextPath()%>/find/pwd',
    method: 'POST',
    data: { loginId: loginId, email: email },
    success: function(res) {
      box.style.display = 'block';
      if (res.sent) {
        box.className = 'authResultBox';
        box.textContent = '임시 비밀번호가 이메일로 전송되었습니다. 로그인 후 비밀번호를 변경해주세요.';
        btn.textContent = '전송 완료';
      } else {
        box.className = 'authResultBox error';
        box.textContent = '일치하는 회원 정보를 찾을 수 없습니다.';
        btn.disabled = false;
        btn.textContent = '임시 비밀번호 전송';
      }
    },
    error: function() {
      box.className = 'authResultBox error';
      box.style.display = 'block';
      box.textContent = '처리 중 오류가 발생했습니다. 다시 시도해주세요.';
      btn.disabled = false;
      btn.textContent = '임시 비밀번호 전송';
    }
  });
}

document.addEventListener('keydown', function(e) {
  if (e.key === 'Enter') findPwd();
});
</script>

<%@ include file="../common/footer.jsp"%>
