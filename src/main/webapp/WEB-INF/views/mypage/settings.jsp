<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file="../common/header.jsp"%>
<%@ include file="../mypage/myPageCategory.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/mypage/settings.css"/>


<div class="settingsWrap">

  <%-- 프로필 이미지 + 닉네임 + 소개글 통합 카드 --%>
  <div class="settingsCard">
    <h3 class="settingsCardTitle">프로필 편집</h3>

    <%-- 프로필 이미지 --%>
    <div class="profileImgArea">
      <div class="profileImgPreview" id="profileImgPreview">
        <img id="profileImgTag"
             src="<%=request.getContextPath()%>/upload/profile/${myPage.profileImg}"
             onerror="this.src='<%=request.getContextPath()%>/images/profile/default_profile.png'"
             alt="프로필">
        <label class="profileImgEdit" for="profileFileInput">
          <ion-icon name="camera-outline"></ion-icon>
        </label>
      </div>
      <input type="file" id="profileFileInput" accept="image/*" style="display:none">
      <p class="settingsHint">JPG, PNG, GIF · 최대 5MB</p>
    </div>

    <%-- 닉네임 --%>
    <div class="settingsGroup" style="margin-top:16px;">
      <label class="settingsLabel">닉네임 <span class="reqBadge">필수</span></label>
      <c:if test="${empty myPage.nickname}">
        <div class="nicknameAlert">
          <ion-icon name="warning-outline"></ion-icon>
          닉네임을 설정해야 채팅과 상품 등록이 가능합니다.
        </div>
      </c:if>
      <div class="settingsInputRow">
        <input type="text" id="nicknameInput" class="settingsInput"
               value="${myPage.nickname}" placeholder="2~12자 닉네임 입력" maxlength="12">
        <button class="settingsInlineBtn" id="nicknameCheckBtn" type="button">중복확인</button>
      </div>
      <p class="settingsMsg" id="nicknameMsg"></p>
    </div>

    <%-- 소개글 --%>
    <div class="settingsGroup" style="margin-top:16px;">
      <label class="settingsLabel">소개글</label>
      <textarea id="introduceInput" class="settingsTextarea"
                placeholder="자신을 소개해보세요 (최대 200자)" maxlength="200">${myPage.introduce}</textarea>
      <p class="settingsHint" id="introduceCount">${fn:length(myPage.introduce)}/200</p>
    </div>

    <button class="settingsSaveBtn" id="profileSaveBtn" disabled>프로필 저장</button>
    <p class="settingsMsg" id="profileMsg"></p>
  </div>

  <%-- 매너온도 --%>
  <div class="settingsCard">
    <h3 class="settingsCardTitle">매너온도</h3>
    <div class="tempDisplay">
      <span class="tempValue">${myPage.temperature}℃</span>
      <div class="tempBar">
        <div class="tempFill" style="width: ${myPage.temperature / 100 * 100}%"></div>
      </div>
      <p class="settingsHint">거래 후 상대방의 평가로 결정됩니다</p>
    </div>
  </div>

  <%-- 계정 정보 --%>
  <div class="settingsCard">
    <h3 class="settingsCardTitle">계정 정보</h3>
    <div class="infoRow"><span class="infoLabel">이름</span><span class="infoVal">${myPage.name}</span></div>
    <div class="infoRow"><span class="infoLabel">이메일</span><span class="infoVal">${myPage.email}</span></div>
    <div class="infoRow">
      <span class="infoLabel">가입 유형</span>
      <span class="infoVal">
        <c:choose>
          <c:when test="${not empty myPage.oauthProvider}">카카오 소셜 로그인</c:when>
          <c:otherwise>일반 회원</c:otherwise>
        </c:choose>
      </span>
    </div>
    <div class="infoRow"><span class="infoLabel">아이디</span><span class="infoVal">${not empty myPage.loginId ? myPage.loginId : '-'}</span></div>
  </div>

  <%-- 비밀번호 변경 (일반 회원만) --%>
  <c:if test="${empty myPage.oauthProvider}">
  <div class="settingsCard">
    <h3 class="settingsCardTitle">비밀번호 변경</h3>
    <div class="settingsGroup">
      <label class="settingsLabel">현재 비밀번호</label>
      <input type="password" id="currentPwd" class="settingsInput" placeholder="현재 비밀번호 입력">
    </div>
    <div class="settingsGroup">
      <label class="settingsLabel">새 비밀번호</label>
      <input type="password" id="newPwd" class="settingsInput" placeholder="8자 이상 영문+숫자+특수문자">
    </div>
    <div class="settingsGroup">
      <label class="settingsLabel">새 비밀번호 확인</label>
      <input type="password" id="confirmPwd" class="settingsInput" placeholder="새 비밀번호 재입력">
    </div>
    <p class="settingsMsg" id="pwdMsg"></p>
    <button class="settingsSaveBtn" id="pwdSaveBtn">비밀번호 변경</button>
  </div>
  </c:if>

</div>

</section>

<script>
var ctx = '<%=request.getContextPath()%>';
var nicknameChecked = false;
var selectedFile = null;

/* ── 프로필 이미지 선택 → 미리보기만 ── */
document.getElementById('profileFileInput').addEventListener('change', function() {
  var file = this.files[0];
  if (!file) return;
  if (file.size > 5 * 1024 * 1024) {
    setMsg('profileMsg', '5MB 이하 이미지만 업로드 가능합니다.', false);
    this.value = '';
    return;
  }
  selectedFile = file;
  var reader = new FileReader();
  reader.onload = function(e) { document.getElementById('profileImgTag').src = e.target.result; };
  reader.readAsDataURL(file);
  enableSaveBtn();
});

/* ── 닉네임 중복확인 ── */
document.getElementById('nicknameCheckBtn').addEventListener('click', function() {
  var nickname = document.getElementById('nicknameInput').value.trim();
  if (!nickname) return;
  $.ajax({
    url: ctx + '/member/mypage/checkNickname',
    data: { nickname: nickname },
    success: function(res) {
      setMsg('nicknameMsg', res.message, res.available);
      nicknameChecked = res.available;
      enableSaveBtn();
    }
  });
});

document.getElementById('nicknameInput').addEventListener('input', function() {
  nicknameChecked = false;
  document.getElementById('profileSaveBtn').disabled = true;
  setMsg('nicknameMsg', '', true);
});

/* ── 소개글 글자수 ── */
document.getElementById('introduceInput').addEventListener('input', function() {
  document.getElementById('introduceCount').textContent = this.value.length + '/200';
});

function enableSaveBtn() {
  document.getElementById('profileSaveBtn').disabled = !nicknameChecked;
}

/* ── 프로필 통합 저장 ── */
document.getElementById('profileSaveBtn').addEventListener('click', function() {
  if (!nicknameChecked) return;
  var nickname  = document.getElementById('nicknameInput').value.trim();
  var introduce = document.getElementById('introduceInput').value;

  var form = new FormData();
  form.append('nickname', nickname);
  form.append('introduce', introduce);
  if (selectedFile) form.append('file', selectedFile);

  $.ajax({
    url: ctx + '/member/mypage/updateProfile',
    method: 'POST',
    data: form,
    processData: false,
    contentType: false,
    success: function(res) {
      if (res.success) {
        setMsg('profileMsg', '프로필이 저장되었습니다.', true);
        nicknameChecked = false;
        selectedFile = null;
        document.getElementById('profileSaveBtn').disabled = true;
        var alert = document.querySelector('.nicknameAlert');
        if (alert) alert.style.display = 'none';
      } else {
        setMsg('profileMsg', res.message, false);
      }
    },
    error: function(xhr) {
      var res = xhr.responseJSON || {};
      setMsg('profileMsg', res.message || '저장 중 오류가 발생했습니다.', false);
    }
  });
});

/* ── 비밀번호 변경 ── */
var pwdBtn = document.getElementById('pwdSaveBtn');
if (pwdBtn) {
  pwdBtn.addEventListener('click', function() {
    var current = document.getElementById('currentPwd').value;
    var newP    = document.getElementById('newPwd').value;
    var confirm = document.getElementById('confirmPwd').value;
    if (!current || !newP || !confirm) {
      setMsg('pwdMsg', '모든 항목을 입력해주세요.', false); return;
    }
    $.ajax({
      url: ctx + '/member/mypage/changePassword',
      method: 'POST',
      data: { currentPwd: current, newPwd: newP, confirmPwd: confirm },
      success: function(res) {
        if (res.success) {
          setMsg('pwdMsg', '비밀번호가 변경되었습니다.', true);
          document.getElementById('currentPwd').value = '';
          document.getElementById('newPwd').value = '';
          document.getElementById('confirmPwd').value = '';
        } else {
          setMsg('pwdMsg', res.message, false);
        }
      },
      error: function(xhr) {
        var res = JSON.parse(xhr.responseText);
        setMsg('pwdMsg', res.message || '오류가 발생했습니다.', false);
      }
    });
  });
}

function setMsg(id, text, ok) {
  var el = document.getElementById(id);
  if (!el) return;
  el.textContent = text;
  el.style.color = ok ? '#059669' : '#dc2626';
}
</script>

<%@ include file="../common/footer.jsp"%>
