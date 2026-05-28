<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file="../common/header.jsp"%>
<%@ include file="../mypage/myPageCategory.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/mypage/myPageMain.css" />

<div class="myPageContent">

  <%-- 프로필 카드 --%>
  <div class="mpProfileCard">
    <div class="mpProfileAvatar">
      <c:choose>
        <c:when test="${fn:startsWith(myPage.profileImg, 'http')}">
          <img src="${myPage.profileImg}" alt="프로필"
               onerror="this.src='<%=request.getContextPath()%>/images/profile/default_profile.png'">
        </c:when>
        <c:otherwise>
          <img src="<%=request.getContextPath()%>${myPage.profileImg}" alt="프로필"
               onerror="this.src='<%=request.getContextPath()%>/images/profile/default_profile.png'">
        </c:otherwise>
      </c:choose>
    </div>
    <div class="mpProfileInfo">
      <div class="mpProfileName">
        <c:choose>
          <c:when test="${not empty myPage.nickname}">${myPage.nickname}</c:when>
          <c:otherwise>${myPage.name}</c:otherwise>
        </c:choose>
        <span class="mpTempBadge" id="tempBadge">${myPage.temperature}℃</span>
      </div>
      <c:if test="${empty myPage.nickname}">
        <a href="<%=request.getContextPath()%>/member/mypage/settings"
           class="mpNicknameBanner">
          <ion-icon name="warning-outline"></ion-icon> 닉네임을 설정해주세요
        </a>
      </c:if>
      <p class="mpProfileSub">
        <c:choose>
          <c:when test="${not empty myPage.introduce}">${myPage.introduce}</c:when>
          <c:otherwise>니꺼내꺼 중고거래 회원</c:otherwise>
        </c:choose>
      </p>
    </div>
    <a href="<%=request.getContextPath()%>/member/mypage/settings" class="mpEditBtn">
      <ion-icon name="create-outline"></ion-icon> 프로필 편집
    </a>
  </div>

  <%-- 거래 통계 --%>
  <div class="mpStatsRow">
    <a href="<%=request.getContextPath()%>/member/mypage/sales?status=SALE" class="mpStatCard">
      <div class="mpStatIcon mpStatIcon--green">
        <ion-icon name="pricetag-outline"></ion-icon>
      </div>
      <div class="mpStatBody">
        <div class="mpStatValue" id="saleCount">-</div>
        <div class="mpStatLabel">판매 중인 상품</div>
      </div>
    </a>
    <a href="<%=request.getContextPath()%>/member/mypage/sales?status=SOLD" class="mpStatCard">
      <div class="mpStatIcon mpStatIcon--blue">
        <ion-icon name="checkmark-circle-outline"></ion-icon>
      </div>
      <div class="mpStatBody">
        <div class="mpStatValue" id="tradeCount">-</div>
        <div class="mpStatLabel">판매완료 상품</div>
      </div>
    </a>
    <a href="<%=request.getContextPath()%>/member/wishlist" class="mpStatCard">
      <div class="mpStatIcon mpStatIcon--pink">
        <ion-icon name="heart-outline"></ion-icon>
      </div>
      <div class="mpStatBody">
        <div class="mpStatValue" id="wishCount">-</div>
        <div class="mpStatLabel">찜한 상품</div>
      </div>
    </a>
  </div>

  <%-- 매너온도 --%>
  <div class="mpSection">
    <div class="mpSectionTitle">
      <ion-icon name="thermometer-outline"></ion-icon> 매너온도
    </div>
    <div class="mpTempCard">
      <div class="mpTempLeft">
        <span class="mpTempNum" id="tempNum">${myPage.temperature}</span>
        <span class="mpTempUnit">℃</span>
        <span class="mpTempGrade" id="tempGrade"></span>
      </div>
      <div class="mpTempRight">
        <div class="mpTempBarWrap">
          <div class="mpTempBar">
            <div class="mpTempFill" id="tempFill" style="width:${myPage.temperature}%"></div>
          </div>
          <div class="mpTempDesc" id="tempDesc"></div>
        </div>
      </div>
    </div>
  </div>

  <%-- 최근 등록 상품 --%>
  <div class="mpSection">
    <div class="mpSectionHeader">
      <span class="mpSectionTitle"><ion-icon name="storefront-outline"></ion-icon> 최근 등록 상품</span>
      <a href="<%=request.getContextPath()%>/member/mypage/sales" class="mpSectionMore">전체보기 →</a>
    </div>
    <div class="mpRecentProducts" id="recentProducts">
      <div class="mpEmptyState">
        <ion-icon name="cube-outline"></ion-icon>
        <p>등록한 상품이 없습니다</p>
        <a href="<%=request.getContextPath()%>/member/sell" class="mpEmptyBtn">상품 등록하기</a>
      </div>
    </div>
  </div>

  <%-- 활동 요약 + 바로가기 2열 --%>
  <div class="mpTwoCol">

    <%-- 활동 요약 --%>
    <div class="mpSection mpSectionHalf">
      <div class="mpSectionTitle"><ion-icon name="bar-chart-outline"></ion-icon> 활동 요약</div>
      <ul class="mpActivityList">
        <li>
          <span class="mpActivityLabel"><ion-icon name="chatbubbles-outline"></ion-icon> 진행 중인 채팅</span>
          <span class="mpActivityVal" id="chatCount">-</span>
        </li>
        <li>
          <span class="mpActivityLabel"><ion-icon name="notifications-outline"></ion-icon> 읽지 않은 알림</span>
          <span class="mpActivityVal" id="unreadNoti">-</span>
        </li>
        <li>
          <span class="mpActivityLabel"><ion-icon name="star-outline"></ion-icon> 받은 후기</span>
          <span class="mpActivityVal" id="reviewCount">-</span>
        </li>
        <li>
          <span class="mpActivityLabel"><ion-icon name="eye-outline"></ion-icon> 상품 조회수 합계</span>
          <span class="mpActivityVal" id="totalViews">-</span>
        </li>
      </ul>
    </div>

    <%-- 계정 정보 --%>
    <div class="mpSection mpSecionHalf">
      <div class="mpSectionTitle"><ion-icon name="shield-checkmark-outline"></ion-icon> 계정 정보</div>
      <ul class="mpActivityList">
        <li>
          <span class="mpActivityLabel"><ion-icon name="person-outline"></ion-icon> 이름</span>
          <span class="mpActivityVal">${myPage.name}</span>
        </li>
        <li>
          <span class="mpActivityLabel"><ion-icon name="mail-outline"></ion-icon> 이메일</span>
          <span class="mpActivityVal mpEmail">${myPage.email}</span>
        </li>
        <li>
          <span class="mpActivityLabel"><ion-icon name="log-in-outline"></ion-icon> 가입 유형</span>
          <span class="mpActivityVal">
            <c:choose>
              <c:when test="${not empty myPage.oauthProvider}">
                <span class="mpBadge mpBadge--kakao">카카오</span>
              </c:when>
              <c:otherwise>
                <span class="mpBadge mpBadge--normal">일반</span>
              </c:otherwise>
            </c:choose>
          </span>
        </li>
        <c:if test="${empty myPage.oauthProvider}">
        <li>
          <span class="mpActivityLabel"><ion-icon name="lock-closed-outline"></ion-icon> 비밀번호</span>
          <a href="<%=request.getContextPath()%>/member/mypage/changePassword" class="mpActivityVal mpLink">변경하기 →</a>
        </li>
        </c:if>
      </ul>
    </div>

  </div>

  <%-- 빠른 메뉴 --%>
  <div class="mpSection">
    <div class="mpSectionTitle"><ion-icon name="grid-outline"></ion-icon> 바로가기</div>
    <div class="mpQuickGrid">
      <a href="<%=request.getContextPath()%>/member/sell" class="mpQuickCard">
        <div class="mpQuickIcon" style="background:#f0fdf8;"><ion-icon name="add-circle-outline" style="color:#20c997;"></ion-icon></div>
        <span>상품 등록</span>
      </a>
      <a href="<%=request.getContextPath()%>/member/wishlist" class="mpQuickCard">
        <div class="mpQuickIcon" style="background:#fff1f3;"><ion-icon name="heart-outline" style="color:#ff4d6d;"></ion-icon></div>
        <span>찜한 상품</span>
      </a>
      <a href="<%=request.getContextPath()%>/member/chat" class="mpQuickCard">
        <div class="mpQuickIcon" style="background:#eff6ff;"><ion-icon name="chatbubbles-outline" style="color:#3b82f6;"></ion-icon></div>
        <span>채팅</span>
      </a>
      <a href="<%=request.getContextPath()%>/member/notilist" class="mpQuickCard">
        <div class="mpQuickIcon" style="background:#faf5ff;"><ion-icon name="notifications-outline" style="color:#8b5cf6;"></ion-icon></div>
        <span>알림</span>
      </a>
      <a href="<%=request.getContextPath()%>/member/mypage/sales" class="mpQuickCard">
        <div class="mpQuickIcon" style="background:#fff7ed;"><ion-icon name="pricetag-outline" style="color:#f97316;"></ion-icon></div>
        <span>판매 내역</span>
      </a>
      <a href="<%=request.getContextPath()%>/member/mypage/purchases" class="mpQuickCard">
        <div class="mpQuickIcon" style="background:#f0f9ff;"><ion-icon name="bag-outline" style="color:#0ea5e9;"></ion-icon></div>
        <span>구매 내역</span>
      </a>
      <a href="<%=request.getContextPath()%>/board/list?notice=N" class="mpQuickCard">
        <div class="mpQuickIcon" style="background:#fefce8;"><ion-icon name="chatbox-ellipses-outline" style="color:#ca8a04;"></ion-icon></div>
        <span>1:1 문의</span>
      </a>
      <a href="<%=request.getContextPath()%>/member/mypage/settings" class="mpQuickCard">
        <div class="mpQuickIcon" style="background:#f8fafc;"><ion-icon name="settings-outline" style="color:#64748b;"></ion-icon></div>
        <span>설정</span>
      </a>
    </div>
  </div>

</div>

</section>

<script>
(function () {
  var ctx = '<%=request.getContextPath()%>';

  /* 매너온도 등급 */
  var temp = parseFloat('${myPage.temperature}') || 36.5;
  var grade, desc, color;
  if      (temp >= 70) { grade='🔥 인기 판매자'; desc='거래 평가가 매우 훌륭해요!'; color='#ef4444'; }
  else if (temp >= 50) { grade='😊 따뜻한 이웃'; desc='신뢰할 수 있는 거래 파트너예요'; color='#f97316'; }
  else if (temp >= 36) { grade='🙂 보통이에요';  desc='꾸준히 좋은 거래를 해보세요'; color='#20c997'; }
  else                 { grade='😥 조금 차가워요';desc='거래 후 매너 평가를 받아보세요'; color='#60a5fa'; }
  document.getElementById('tempGrade').textContent = grade;
  document.getElementById('tempDesc').textContent  = desc;
  document.getElementById('tempFill').style.background = color;
  document.getElementById('tempBadge').style.background = color + '33';
  document.getElementById('tempBadge').style.color = color;

  /* 찜 수 */
  $.ajax({ url: ctx + '/member/wish/count', success: function(r) {
    document.getElementById('wishCount').textContent = r && r.count !== undefined ? r.count : 0;
  }, error: function() { document.getElementById('wishCount').textContent = 0; }});

  /* 판매중 상품 수 */
  $.ajax({ url: ctx + '/member/mypage/stats', success: function(r) {
    if (!r) return;
    document.getElementById('saleCount').textContent  = r.saleCount  ?? 0;
    document.getElementById('tradeCount').textContent = r.tradeCount ?? 0;
    document.getElementById('chatCount').textContent  = r.chatCount  ?? 0;
    document.getElementById('unreadNoti').textContent = r.unreadNoti ?? 0;
    document.getElementById('reviewCount').textContent= r.reviewCount?? 0;
    document.getElementById('totalViews').textContent = r.totalViews ?? 0;
  }, error: function() {
    ['saleCount','tradeCount','chatCount','unreadNoti','reviewCount','totalViews']
      .forEach(function(id){ document.getElementById(id).textContent = 0; });
  }});

  /* 최근 등록 상품 */
  $.ajax({ url: ctx + '/member/mypage/recentProducts', success: function(list) {
    if (!list || list.length === 0) return;
    var html = list.map(function(p) {
      var imgSrc = p.imgFile ? ctx + p.imgFile : ctx + '/images/common/hifiveLogo.png';
      var statusLabel = p.status === 'SALE' ? '판매중' : p.status === 'RESERVED' ? '예약중' : '거래완료';
      var statusClass = p.status === 'SALE' ? 'status-sale' : p.status === 'RESERVED' ? 'status-reserved' : 'status-done';
      return '<a href="' + ctx + '/product/' + p.productId + '" class="mpProductItem">' +
        '<img src="' + imgSrc + '" onerror="this.src=\'' + ctx + '/images/common/hifiveLogo.png\'">' +
        '<div class="mpProductInfo">' +
          '<p class="mpProductTitle">' + p.title + '</p>' +
          '<p class="mpProductPrice">' + Number(p.price).toLocaleString() + '원</p>' +
          '<span class="mpProductStatus ' + statusClass + '">' + statusLabel + '</span>' +
        '</div>' +
      '</a>';
    }).join('');
    document.getElementById('recentProducts').innerHTML = html;
  }});
})();
</script>

<%@ include file="../common/footer.jsp"%>
