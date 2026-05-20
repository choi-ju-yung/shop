<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/user/sellerProfile.css"/>

<div class="spWrap">

  <%-- 프로필 헤더 카드 --%>
  <div class="spProfileCard">
    <div class="spAvatar">
      <c:choose>
        <c:when test="${not empty seller.profileImg}">
          <img src="${fn:startsWith(seller.profileImg, 'http') ? seller.profileImg : pageContext.request.contextPath.concat('/upload/profile/').concat(seller.profileImg)}"
               alt="프로필"
               onerror="this.src='<%=request.getContextPath()%>/images/profile/default_profile.png'">
        </c:when>
        <c:otherwise>
          <img src="<%=request.getContextPath()%>/images/profile/default_profile.png" alt="프로필">
        </c:otherwise>
      </c:choose>
    </div>

    <div class="spProfileBody">
      <div class="spNameRow">
        <span class="spNickname">
          <c:choose>
            <c:when test="${not empty seller.nickname}">${seller.nickname}</c:when>
            <c:otherwise>${seller.name}</c:otherwise>
          </c:choose>
        </span>
        <span class="spTempPill" id="spTempPill">
          <ion-icon name="thermometer-outline"></ion-icon>
          <span id="spTempVal">${seller.temperature}℃</span>
        </span>
        <span class="spTempGrade" id="spTempGrade"></span>
      </div>

      <p class="spIntroduce">
        <c:choose>
          <c:when test="${not empty seller.introduce}">${seller.introduce}</c:when>
          <c:otherwise>니꺼내꺼 중고거래 회원</c:otherwise>
        </c:choose>
      </p>

      <div class="spTempBarRow">
        <span class="spTempBarLabel">매너온도</span>
        <span class="spTempNum" id="spTempNum">${seller.temperature}℃</span>
        <div class="spTempTrack">
          <div class="spTempFill" id="spTempFill" style="width:${seller.temperature}%;"></div>
        </div>
      </div>
    </div>

    <c:if test="${isOwn}">
      <a href="<%=request.getContextPath()%>/member/mypage/settings" class="spEditBtn">
        <ion-icon name="create-outline"></ion-icon> 프로필 편집
      </a>
    </c:if>
  </div>

  <%-- 받은 후기 링크 카드 --%>
  <a href="<%=request.getContextPath()%>/user/profile/${encodedSellerNo}/reviews" class="spReviewLinkCard">
    <div class="spReviewLinkLeft">
      <ion-icon name="star"></ion-icon>
      <span class="spReviewLinkTitle">받은 후기</span>
      <c:choose>
        <c:when test="${reviewCount > 0}">
          <span class="spReviewLinkCount">${reviewCount}개</span>
          <span class="spReviewLinkStars" id="spLinkStars"></span>
          <span class="spReviewLinkAvg" id="spLinkAvg">${avgRating}</span>
        </c:when>
        <c:otherwise>
          <span class="spReviewLinkNone">아직 후기가 없어요</span>
        </c:otherwise>
      </c:choose>
    </div>
    <ion-icon name="chevron-forward-outline" class="spReviewLinkArrow"></ion-icon>
  </a>

  <%-- 판매 상품 섹션 --%>
  <div class="spSection">
    <div class="spSectionHeader">
      <div class="spSectionTitle">
        <ion-icon name="storefront-outline"></ion-icon> 판매 상품
      </div>
      <div class="spTabs">
        <a href="?status=ALL"      class="spTab ${currentStatus == 'ALL'      ? 'active' : ''}">전체</a>
        <a href="?status=SALE"     class="spTab ${currentStatus == 'SALE'     ? 'active' : ''}">판매중</a>
        <a href="?status=RESERVED" class="spTab ${currentStatus == 'RESERVED' ? 'active' : ''}">예약중</a>
        <a href="?status=SOLD"     class="spTab ${currentStatus == 'SOLD'     ? 'active' : ''}">판매완료</a>
      </div>
    </div>

    <div class="spListMeta">총 <strong>${products.size()}</strong>개</div>

    <c:choose>
      <c:when test="${empty products}">
        <div class="spEmpty">
          <ion-icon name="cube-outline"></ion-icon>
          <p>등록된 상품이 없습니다</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="spProductGrid">
          <c:forEach var="p" items="${products}">
            <a href="<%=request.getContextPath()%>/product/${p.productId}" class="spProductCard">
              <div class="spProductImgWrap">
                <c:choose>
                  <c:when test="${not empty p.mainFilePath}">
                    <img src="<%=request.getContextPath()%>${p.mainFilePath}"
                         alt="<c:out value='${p.title}'/>"
                         onerror="this.src='<%=request.getContextPath()%>/images/common/hifiveLogo.png'">
                  </c:when>
                  <c:otherwise>
                    <img src="<%=request.getContextPath()%>/images/common/hifiveLogo.png" alt="이미지 없음">
                  </c:otherwise>
                </c:choose>
                <c:if test="${p.tradeStatus == 'SOLD'}"><div class="spStatusDim">판매완료</div></c:if>
                <c:if test="${p.tradeStatus == 'RESERVED'}"><div class="spStatusDim">예약중</div></c:if>
                <c:choose>
                  <c:when test="${p.tradeStatus == 'SALE'}"><span class="spStatusBadge spBadge-SALE">판매중</span></c:when>
                  <c:when test="${p.tradeStatus == 'RESERVED'}"><span class="spStatusBadge spBadge-RESERVED">예약중</span></c:when>
                  <c:when test="${p.tradeStatus == 'SOLD'}"><span class="spStatusBadge spBadge-SOLD">판매완료</span></c:when>
                </c:choose>
              </div>
              <div class="spProductInfo">
                <p class="spProductTitle"><c:out value="${p.title}"/></p>
                <p class="spProductPrice"><fmt:formatNumber value="${p.price}" pattern="#,###"/>원</p>
                <p class="spProductMeta"><c:out value="${not empty p.place ? p.place : '지역 미설정'}"/></p>
              </div>
            </a>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

</div>

<script>
(function () {
  var temp  = parseFloat('${seller.temperature}') || 36.5;
  var color, grade;
  if      (temp >= 70) { color = '#ef4444'; grade = '🔥 인기 판매자'; }
  else if (temp >= 50) { color = '#f97316'; grade = '😊 따뜻한 이웃'; }
  else if (temp >= 36) { color = '#20c997'; grade = '🙂 보통이에요';  }
  else                 { color = '#60a5fa'; grade = '😥 조금 차가워요'; }

  var pill    = document.getElementById('spTempPill');
  var val     = document.getElementById('spTempVal');
  var num     = document.getElementById('spTempNum');
  var fill    = document.getElementById('spTempFill');
  var gradeEl = document.getElementById('spTempGrade');

  if (pill)    { pill.style.background = color + '22'; pill.style.color = color; }
  if (val)     val.style.color = color;
  if (num)     num.style.color = color;
  if (fill)    fill.style.background = color;
  if (gradeEl) gradeEl.textContent = grade;

  /* 후기 링크 카드 별점 미리보기 (소수점 지원) */
  var linkStars = document.getElementById('spLinkStars');
  if (linkStars) {
    var avg = parseFloat('${avgRating}') || 0;
    var html = '';
    for (var i = 1; i <= 5; i++) {
      if (avg >= i) {
        html += '<span style="color:#f59e0b;font-size:14px;">&#9733;</span>';
      } else if (avg > i - 1) {
        var pct = Math.round((avg - (i - 1)) * 100);
        html += '<span style="display:inline-block;background:linear-gradient(90deg,#f59e0b ' + pct + '%,#e5e7eb ' + pct + '%);' +
                '-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;font-size:14px;">&#9733;</span>';
      } else {
        html += '<span style="color:#e5e7eb;font-size:14px;">&#9733;</span>';
      }
    }
    linkStars.innerHTML = html;
  }
})();
</script>

<%@ include file="../common/footer.jsp"%>
