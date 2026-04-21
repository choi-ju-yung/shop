<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/user/sellerReviews.css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/common/pagination.css"/>

<div class="srWrap">

  <%-- 뒤로가기 --%>
  <a href="<%=request.getContextPath()%>/user/profile/${encodedSellerNo}" class="srBackBtn">
    <div class="srBackArrow">
      <ion-icon name="chevron-back-outline"></ion-icon>
    </div>
    <div class="srBackInfo">
      <span class="srBackName">
        <c:choose>
          <c:when test="${not empty seller.nickname}">${seller.nickname}</c:when>
          <c:otherwise>${seller.name}</c:otherwise>
        </c:choose>
      </span>
      <span class="srBackSub">프로필로 돌아가기</span>
    </div>
  </a>

  <%-- 헤더 --%>
  <div class="srHeader">
    <div class="srHeaderLeft">
      <div class="srHeaderIcon">
        <ion-icon name="star"></ion-icon>
      </div>
      <div>
        <p class="srHeaderTitle">받은 후기</p>
        <p class="srHeaderSub">구매자들이 남긴 거래 후기입니다</p>
      </div>
    </div>

    <c:if test="${reviewCount > 0}">
      <div class="srSummaryCard">
        <div class="srSummaryScore">
          <span class="srSummaryNum">${avgRating}</span>
          <span class="srSummaryMax">/5</span>
        </div>
        <div class="srSummaryRight">
          <div class="srSummaryStars" id="summaryStars"></div>
          <p class="srSummaryCount">후기 ${reviewCount}개</p>
        </div>
      </div>
    </c:if>
  </div>

  <%-- 리뷰 목록 --%>
  <c:choose>
    <c:when test="${empty reviews}">
      <div class="srEmpty">
        <ion-icon name="chatbubble-outline"></ion-icon>
        <p class="srEmptyTitle">아직 받은 후기가 없어요</p>
        <p class="srEmptySub">거래를 완료하면 구매자가 후기를 남길 수 있어요</p>
      </div>
    </c:when>
    <c:otherwise>
      <c:set var="pageBaseUrl" value="?"/>
      <div class="srGrid">
        <c:forEach var="r" items="${reviews}">
          <div class="srCard">

            <div class="srCardTop">
              <div class="srCardAvatar">
                <ion-icon name="person-circle-outline"></ion-icon>
              </div>
              <div class="srCardMeta">
                <span class="srCardName"><c:out value="${r.reviewerName}"/></span>
                <span class="srCardDate">
                  <fmt:formatDate value="${r.regDate}" pattern="yyyy.MM.dd"/>
                </span>
              </div>
              <div class="srCardStars" data-rating="${r.rating}"></div>
            </div>

            <a href="<%=request.getContextPath()%>/product/${r.productId}" class="srProductTag">
              <ion-icon name="cube-outline"></ion-icon>
              <c:out value="${r.productTitle}"/>
            </a>

            <c:choose>
              <c:when test="${not empty r.content}">
                <p class="srContent"><c:out value="${r.content}"/></p>
              </c:when>
              <c:otherwise>
                <p class="srNoContent">내용 없이 별점만 남긴 후기입니다.</p>
              </c:otherwise>
            </c:choose>

          </div>
        </c:forEach>
      </div>

      <%@ include file="../common/pagination.jsp"%>
    </c:otherwise>
  </c:choose>

</div>

<script>
(function () {
  var starColors = ['', '#ef4444', '#f97316', '#eab308', '#22c55e', '#20c997'];

  function renderStars(container, rating, size) {
    size = size || 15;
    var color = starColors[Math.round(rating)] || '#eab308';
    var h = '';
    for (var i = 1; i <= 5; i++) {
      if (rating >= i) {
        h += '<span style="color:' + color + ';font-size:' + size + 'px;">&#9733;</span>';
      } else if (rating > i - 1) {
        var pct = Math.round((rating - (i - 1)) * 100);
        h += '<span style="display:inline-block;background:linear-gradient(90deg,' + color + ' ' + pct + '%,#e5e7eb ' + pct + '%);' +
             '-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;' +
             'font-size:' + size + 'px;">&#9733;</span>';
      } else {
        h += '<span style="color:#e5e7eb;font-size:' + size + 'px;">&#9733;</span>';
      }
    }
    container.innerHTML = h;
  }

  // 각 카드 별점 (정수)
  document.querySelectorAll('.srCardStars').forEach(function (el) {
    renderStars(el, parseInt(el.dataset.rating), 15);
  });

  // 요약 별점 (소수점 평균)
  var summaryEl = document.getElementById('summaryStars');
  if (summaryEl) {
    renderStars(summaryEl, parseFloat('${avgRating}') || 0, 18);
  }
})();
</script>

<%@ include file="../common/footer.jsp"%>
