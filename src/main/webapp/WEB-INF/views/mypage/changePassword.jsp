<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../common/header.jsp"%>
<%@ include file="../mypage/myPageCategory.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/mypage/changePassword.css"/>

<div class="myPageContent">
  <div class="cpWrap">

    <%-- 상단 헤더 --%>
    <div class="cpHeader">
      <div class="cpHeaderIcon">
        <ion-icon name="lock-closed"></ion-icon>
      </div>
      <div>
        <h2 class="cpHeaderTitle">비밀번호 변경</h2>
        <p class="cpHeaderSub">주기적인 비밀번호 변경으로 계정을 안전하게 보호하세요.</p>
      </div>
    </div>

    <%-- 안내 배너 --%>
    <div class="cpInfoBanner">
      <ion-icon name="shield-checkmark-outline"></ion-icon>
      <span>비밀번호는 <b>8자 이상</b>, <b>영문 + 숫자 + 특수문자</b>를 포함해야 합니다.</span>
    </div>

    <%-- 폼 --%>
    <div class="cpCard">

      <div class="cpField">
        <label class="cpLabel">현재 비밀번호</label>
        <div class="cpInputWrap">
          <ion-icon name="lock-closed-outline" class="cpInputIcon"></ion-icon>
          <input type="password" id="currentPwd" class="cpInput" placeholder="현재 비밀번호 입력">
          <button type="button" class="cpEyeBtn" data-target="currentPwd">
            <ion-icon name="eye-outline"></ion-icon>
          </button>
        </div>
      </div>

      <div class="cpDivider"></div>

      <div class="cpField">
        <label class="cpLabel">새 비밀번호</label>
        <div class="cpInputWrap">
          <ion-icon name="key-outline" class="cpInputIcon"></ion-icon>
          <input type="password" id="newPwd" class="cpInput" placeholder="새 비밀번호 입력">
          <button type="button" class="cpEyeBtn" data-target="newPwd">
            <ion-icon name="eye-outline"></ion-icon>
          </button>
        </div>
        <%-- 강도 게이지 --%>
        <div class="cpStrengthBar">
          <div class="cpStrengthFill" id="strengthFill"></div>
        </div>
        <p class="cpStrengthLabel" id="strengthLabel"></p>
        <%-- 조건 체크리스트 --%>
        <ul class="cpChecklist">
          <li id="chk-len"><ion-icon name="ellipse-outline"></ion-icon> 8자 이상</li>
          <li id="chk-upper"><ion-icon name="ellipse-outline"></ion-icon> 대문자 포함</li>
          <li id="chk-lower"><ion-icon name="ellipse-outline"></ion-icon> 소문자 포함</li>
          <li id="chk-num"><ion-icon name="ellipse-outline"></ion-icon> 숫자 포함</li>
          <li id="chk-spc"><ion-icon name="ellipse-outline"></ion-icon> 특수문자 포함</li>
        </ul>
      </div>

      <div class="cpField">
        <label class="cpLabel">새 비밀번호 확인</label>
        <div class="cpInputWrap">
          <ion-icon name="checkmark-circle-outline" class="cpInputIcon"></ion-icon>
          <input type="password" id="confirmPwd" class="cpInput" placeholder="새 비밀번호 재입력">
          <button type="button" class="cpEyeBtn" data-target="confirmPwd">
            <ion-icon name="eye-outline"></ion-icon>
          </button>
        </div>
        <p class="cpMsg" id="confirmMsg"></p>
      </div>

      <p class="cpResultMsg" id="resultMsg"></p>

      <button class="cpSaveBtn" id="saveBtn">
        <ion-icon name="checkmark-outline"></ion-icon>
        비밀번호 변경
      </button>
    </div>

  </div>
</div>

</section>

<script>
var ctx = '<%=request.getContextPath()%>';

/* ── 눈 아이콘 토글 ── */
document.querySelectorAll('.cpEyeBtn').forEach(function(btn) {
  btn.addEventListener('click', function() {
    var input = document.getElementById(this.dataset.target);
    var icon  = this.querySelector('ion-icon');
    if (input.type === 'password') {
      input.type = 'text';
      icon.setAttribute('name', 'eye-off-outline');
    } else {
      input.type = 'password';
      icon.setAttribute('name', 'eye-outline');
    }
  });
});

/* ── 새 비밀번호 강도 ── */
document.getElementById('newPwd').addEventListener('input', function() {
  var v = this.value;
  var len   = v.length >= 8;
  var upper = /[A-Z]/.test(v);
  var lower = /[a-z]/.test(v);
  var num   = /[0-9]/.test(v);
  var spc   = /[^a-zA-Z0-9]/.test(v);
  var score = [len, upper, lower, num, spc].filter(Boolean).length;

  setCheck('chk-len',   len);
  setCheck('chk-upper', upper);
  setCheck('chk-lower', lower);
  setCheck('chk-num',   num);
  setCheck('chk-spc',   spc);

  var pct    = score * 20;
  var fill   = document.getElementById('strengthFill');
  var label  = document.getElementById('strengthLabel');
  var colors = ['', '#ef4444', '#f97316', '#eab308', '#84cc16', '#20c997'];
  fill.style.width      = pct + '%';
  fill.style.background = colors[score] || '';
  label.textContent     = v.length ? pct + '%' : '';
  label.style.color     = colors[score] || '';

  /* 현재 비밀번호와 동일한지 실시간 체크 */
  var cur = document.getElementById('currentPwd').value;
  if (cur && v && cur === v) {
    setMsg('resultMsg', '현재 비밀번호와 동일한 비밀번호는 사용할 수 없습니다.', false);
  } else {
    setMsg('resultMsg', '', true);
  }

  checkConfirm();
});

function setCheck(id, ok) {
  var el   = document.getElementById(id);
  var icon = el.querySelector('ion-icon');
  if (ok) {
    el.classList.add('done');
    icon.setAttribute('name', 'checkmark-circle');
  } else {
    el.classList.remove('done');
    icon.setAttribute('name', 'ellipse-outline');
  }
}

/* ── 비밀번호 확인 ── */
document.getElementById('confirmPwd').addEventListener('input', checkConfirm);

function checkConfirm() {
  var np = document.getElementById('newPwd').value;
  var cp = document.getElementById('confirmPwd').value;
  if (!cp.length) { setMsg('confirmMsg', '', true); return; }
  var ok = np === cp;
  setMsg('confirmMsg', ok ? '비밀번호가 일치합니다.' : '비밀번호가 일치하지 않습니다.', ok);
}

/* ── 저장 ── */
document.getElementById('saveBtn').addEventListener('click', function() {
  var current = document.getElementById('currentPwd').value;
  var newP    = document.getElementById('newPwd').value;
  var confirm = document.getElementById('confirmPwd').value;

  if (!current || !newP || !confirm) {
    setMsg('resultMsg', '모든 항목을 입력해주세요.', false); return;
  }
  if (current === newP) {
    setMsg('resultMsg', '현재 비밀번호와 동일한 비밀번호는 사용할 수 없습니다.', false); return;
  }
  if (newP !== confirm) {
    setMsg('resultMsg', '새 비밀번호가 일치하지 않습니다.', false); return;
  }
  var len   = newP.length >= 8;
  var upper = /[A-Z]/.test(newP);
  var lower = /[a-z]/.test(newP);
  var num   = /[0-9]/.test(newP);
  var spc   = /[^a-zA-Z0-9]/.test(newP);
  if (!len || !upper || !lower || !num || !spc) {
    setMsg('resultMsg', '비밀번호 조건을 100% 충족해야 변경할 수 있습니다.', false); return;
  }

  $.ajax({
    url: ctx + '/member/mypage/changePassword',
    method: 'POST',
    data: { currentPwd: current, newPwd: newP, confirmPwd: confirm },
    success: function(res) {
      if (res.success) {
        setMsg('resultMsg', '✓ 비밀번호가 성공적으로 변경되었습니다.', true);
        document.getElementById('currentPwd').value = '';
        document.getElementById('newPwd').value = '';
        document.getElementById('confirmPwd').value = '';
        document.getElementById('strengthFill').style.width = '0';
        document.getElementById('strengthLabel').textContent = '';
        document.getElementById('confirmMsg').textContent = '';
        ['chk-len','chk-upper','chk-lower','chk-num','chk-spc'].forEach(function(id) { setCheck(id, false); });
      } else {
        setMsg('resultMsg', res.message, false);
      }
    },
    error: function(xhr) {
      var res = xhr.responseJSON || {};
      setMsg('resultMsg', res.message || '오류가 발생했습니다.', false);
    }
  });
});

function setMsg(id, text, ok) {
  var el = document.getElementById(id);
  if (!el) return;
  el.textContent = text;
  el.style.color = ok ? '#059669' : '#dc2626';
}
</script>

<%@ include file="../common/footer.jsp"%>
