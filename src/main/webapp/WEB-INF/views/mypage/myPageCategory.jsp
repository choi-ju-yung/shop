<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/mypage/myPageCategory.css" />

<section>
  <div class="mypageCategory">

    <div class="mypageSideSection">
      <p class="mypageSideLabel">마이페이지</p>
      <ul class="mypageSideMenu">
        <li><a href="<%=request.getContextPath()%>/member/mypage">
          <ion-icon name="home-outline"></ion-icon> 홈
        </a></li>
      </ul>
    </div>

    <hr class="mypageSideDivider">

    <div class="mypageSideSection">
      <p class="mypageSideLabel">나의 쇼핑</p>
      <ul class="mypageSideMenu">
        <li><a href="<%=request.getContextPath()%>/member/mypage/purchases">
          <ion-icon name="bag-outline"></ion-icon> 구매 내역
        </a></li>
        <li><a href="<%=request.getContextPath()%>/member/mypage/sales">
          <ion-icon name="pricetag-outline"></ion-icon> 판매 내역
        </a></li>
        <li><a href="<%=request.getContextPath()%>/member/wishlist">
          <ion-icon name="heart-outline"></ion-icon> 찜한 상품
        </a></li>
        <li><a href="<%=request.getContextPath()%>/member/review/received">
          <ion-icon name="star-outline"></ion-icon> 받은 후기
        </a></li>
        <li><a href="<%=request.getContextPath()%>/member/notilist">
          <ion-icon name="notifications-outline"></ion-icon> 알림
        </a></li>
      </ul>
    </div>

    <hr class="mypageSideDivider">

    <div class="mypageSideSection">
      <p class="mypageSideLabel">내 정보</p>
      <ul class="mypageSideMenu">
        <li><a href="<%=request.getContextPath()%>/member/mypage/settings">
          <ion-icon name="person-circle-outline"></ion-icon> 프로필 설정
        </a></li>
        <c:if test="${empty sessionScope.loginUser.oauthProvider}">
        <li><a href="<%=request.getContextPath()%>/member/mypage/changePassword">
          <ion-icon name="lock-closed-outline"></ion-icon> 비밀번호 변경
        </a></li>
        </c:if>
        <li><a href="#" style="color:#f87171;" onclick="confirmWithdraw(event)">
          <ion-icon name="trash-outline" style="color:#f87171;"></ion-icon> 회원탈퇴
        </a></li>
      </ul>
    </div>

    <hr class="mypageSideDivider">

    <div class="mypageSideSection">
      <p class="mypageSideLabel">고객센터</p>
      <ul class="mypageSideMenu">
        <li><a href="<%=request.getContextPath()%>/board/list?notice=N">
          <ion-icon name="chatbox-ellipses-outline"></ion-icon> 1:1 문의
        </a></li>
        <li><a href="<%=request.getContextPath()%>/board/list?notice=Y">
          <ion-icon name="megaphone-outline"></ion-icon> 공지사항
        </a></li>
      </ul>
    </div>

  </div>

  <%-- 회원탈퇴 경고 모달 --%>
  <div id="withdrawModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.55);z-index:9999;align-items:center;justify-content:center;">
    <div style="background:#fff;border-radius:16px;width:92%;max-width:440px;overflow:hidden;box-shadow:0 16px 48px rgba(0,0,0,0.25);">

      <%-- 헤더 --%>
      <div style="background:#dc2626;padding:22px 24px;display:flex;align-items:center;gap:12px;">
        <ion-icon name="warning" style="font-size:28px;color:#fff;flex-shrink:0;"></ion-icon>
        <div>
          <p style="margin:0;font-size:17px;font-weight:700;color:#fff;">정말 탈퇴하시겠습니까?</p>
          <p style="margin:4px 0 0;font-size:12px;color:#fca5a5;">탈퇴 후에는 계정을 복구할 수 없습니다</p>
        </div>
      </div>

      <%-- 경고 내용 --%>
      <div style="padding:22px 24px 0;">
        <p style="margin:0 0 14px;font-size:13px;font-weight:700;color:#374151;">탈퇴 시 아래 데이터가 모두 삭제됩니다</p>
        <ul style="margin:0 0 18px;padding:0;list-style:none;display:flex;flex-direction:column;gap:9px;">
          <li style="display:flex;align-items:flex-start;gap:8px;font-size:13px;color:#4b5563;">
            <ion-icon name="close-circle" style="color:#dc2626;font-size:16px;flex-shrink:0;margin-top:1px;"></ion-icon>
            <span><b>등록한 상품</b> 및 상품 이미지가 모두 삭제됩니다</span>
          </li>
          <li style="display:flex;align-items:flex-start;gap:8px;font-size:13px;color:#4b5563;">
            <ion-icon name="close-circle" style="color:#dc2626;font-size:16px;flex-shrink:0;margin-top:1px;"></ion-icon>
            <span><b>찜 목록</b>, <b>알림 내역</b>이 영구 삭제됩니다</span>
          </li>
          <li style="display:flex;align-items:flex-start;gap:8px;font-size:13px;color:#4b5563;">
            <ion-icon name="close-circle" style="color:#dc2626;font-size:16px;flex-shrink:0;margin-top:1px;"></ion-icon>
            <span><b>채팅 내역</b>은 상대방 화면에 익명으로 유지됩니다</span>
          </li>
          <li style="display:flex;align-items:flex-start;gap:8px;font-size:13px;color:#4b5563;">
            <ion-icon name="close-circle" style="color:#dc2626;font-size:16px;flex-shrink:0;margin-top:1px;"></ion-icon>
            <span>탈퇴 후 <b>30일간 동일 계정으로 재가입이 제한</b>됩니다</span>
          </li>
        </ul>

        <div style="background:#fef9c3;border:1px solid #fde047;border-radius:8px;padding:11px 13px;margin-bottom:18px;display:flex;gap:8px;align-items:flex-start;">
          <ion-icon name="information-circle" style="color:#ca8a04;font-size:16px;flex-shrink:0;margin-top:1px;"></ion-icon>
          <p style="margin:0;font-size:12px;color:#854d0e;line-height:1.6;">
            회원 정보는 <b>개인정보 보호법</b>에 따라 탈퇴일로부터 <b>5년간 보관</b> 후 완전 파기됩니다.
          </p>
        </div>

        <%-- 동의 체크박스 --%>
        <label style="display:flex;align-items:center;gap:9px;cursor:pointer;margin-bottom:20px;padding:12px;border:1.5px solid #e5e7eb;border-radius:8px;transition:border-color 0.2s;"
               id="withdrawAgreeLabel">
          <input type="checkbox" id="withdrawAgree" style="width:16px;height:16px;accent-color:#dc2626;cursor:pointer;"
                 onchange="toggleWithdrawBtn()">
          <span style="font-size:13px;color:#374151;font-weight:600;">안내 사항을 모두 확인했으며 탈퇴에 동의합니다</span>
        </label>
      </div>

      <%-- 버튼 --%>
      <div style="display:flex;gap:10px;padding:0 24px 22px;">
        <button onclick="closeWithdrawModal()"
                style="flex:1;padding:12px;border:1px solid #d1d5db;border-radius:9px;background:#fff;font-size:14px;font-weight:600;color:#6b7280;cursor:pointer;font-family:inherit;transition:background 0.2s;"
                onmouseover="this.style.background='#f3f4f6'" onmouseout="this.style.background='#fff'">
          취소
        </button>
        <button id="withdrawConfirmBtn" onclick="doWithdraw()" disabled
                style="flex:1;padding:12px;border:none;border-radius:9px;background:#e5e7eb;font-size:14px;font-weight:700;color:#9ca3af;cursor:not-allowed;font-family:inherit;transition:all 0.2s;">
          탈퇴하기
        </button>
      </div>

    </div>
  </div>

  <script src="<%=request.getContextPath()%>/js/mypage/myPageCategory.js"></script>
  <script>
  function confirmWithdraw(e) {
    e.preventDefault();
    document.getElementById('withdrawAgree').checked = false;
    toggleWithdrawBtn();
    document.getElementById('withdrawModal').style.display = 'flex';
  }

  function closeWithdrawModal() {
    document.getElementById('withdrawModal').style.display = 'none';
  }

  function toggleWithdrawBtn() {
    var checked = document.getElementById('withdrawAgree').checked;
    var btn     = document.getElementById('withdrawConfirmBtn');
    var label   = document.getElementById('withdrawAgreeLabel');
    if (checked) {
      btn.disabled             = false;
      btn.style.background     = '#dc2626';
      btn.style.color          = '#fff';
      btn.style.cursor         = 'pointer';
      label.style.borderColor  = '#dc2626';
    } else {
      btn.disabled             = true;
      btn.style.background     = '#e5e7eb';
      btn.style.color          = '#9ca3af';
      btn.style.cursor         = 'not-allowed';
      label.style.borderColor  = '#e5e7eb';
    }
  }

  function doWithdraw() {
    $.ajax({
      url: '<%=request.getContextPath()%>/member/withdraw',
      method: 'DELETE',
      success: function () {
        closeWithdrawModal();
        alert('탈퇴가 완료되었습니다.\n그동안 이용해 주셔서 감사합니다.');
        location.href = '<%=request.getContextPath()%>/main';
      },
      error: function () {
        alert('탈퇴 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
      }
    });
  }

  // 모달 외부 클릭 시 닫기
  document.getElementById('withdrawModal').addEventListener('click', function(e) {
    if (e.target === this) closeWithdrawModal();
  });
  </script>
