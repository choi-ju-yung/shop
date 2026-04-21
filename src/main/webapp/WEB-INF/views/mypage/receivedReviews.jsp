<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../common/header.jsp"%>
<%@ include file="../mypage/myPageCategory.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/mypage/receivedReviews.css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/common/pagination.css"/>

<div class="rrPageWrap">

  <%-- 헤더 --%>
  <div class="rrHeader">
    <div class="rrHeaderLeft">
      <div class="rrHeaderIcon">
        <ion-icon name="star"></ion-icon>
      </div>
      <div>
        <h2 class="rrHeaderTitle">받은 후기</h2>
        <p class="rrHeaderSub">구매자들이 남긴 거래 후기입니다</p>
      </div>
    </div>

    <c:if test="${reviewCount > 0}">
      <div class="rrSummaryCard">
        <div class="rrSummaryScore">
          <span class="rrSummaryNum">${avgRating}</span>
          <span class="rrSummaryMax">/5</span>
        </div>
        <div class="rrSummaryStars" id="summaryStars"></div>
        <p class="rrSummaryCount">후기 ${reviewCount}개</p>
      </div>
    </c:if>
  </div>

  <c:choose>
    <c:when test="${empty reviews}">
      <div class="rrEmpty">
        <ion-icon name="chatbubble-outline"></ion-icon>
        <p class="rrEmptyTitle">아직 받은 후기가 없어요</p>
        <p class="rrEmptySub">거래를 완료하면 구매자가 후기를 남길 수 있어요</p>
        <a href="<%=request.getContextPath()%>/member/mypage/sales" class="rrEmptyBtn">
          <ion-icon name="pricetag-outline"></ion-icon> 판매 내역 보기
        </a>
      </div>
    </c:when>
    <c:otherwise>
      <c:set var="pageBaseUrl" value="?"/>
      <div class="rrList">
        <c:forEach var="r" items="${reviews}">
          <div class="rrCard">

            <%-- 카드 상단: 작성자 + 날짜 --%>
            <div class="rrCardTop">
              <div class="rrCardAvatar">
                <ion-icon name="person-circle-outline"></ion-icon>
              </div>
              <div class="rrCardMeta">
                <span class="rrCardName"><c:out value="${r.reviewerName}"/></span>
                <span class="rrCardDate">
                  <fmt:formatDate value="${r.regDate}" type="date" pattern="yyyy.MM.dd"/>
                </span>
              </div>
              <div class="rrCardStars" data-rating="${r.rating}"></div>
            </div>

            <%-- 상품 태그 --%>
            <a href="<%=request.getContextPath()%>/product/${r.productId}" class="rrProductTag">
              <ion-icon name="cube-outline"></ion-icon>
              <c:out value="${r.productTitle}"/>
            </a>

            <%-- 후기 내용 --%>
            <c:if test="${not empty r.content}">
              <p class="rrCardContent"><c:out value="${r.content}"/></p>
            </c:if>
            <c:if test="${empty r.content}">
              <p class="rrCardNoContent">내용 없이 별점만 남긴 후기입니다.</p>
            </c:if>

          </div>
        </c:forEach>
      </div>
      <%@ include file="../common/pagination.jsp"%>
    </c:otherwise>
  </c:choose>

</div>

</section>

<script>
(function () {
  var starColors = ['', '#ef4444', '#f97316', '#eab308', '#22c55e', '#20c997'];

  function renderStars(container, rating, size) {
    size = size || 16;
    var color = starColors[Math.round(rating)] || '#eab308';
    var html = '';
    for (var i = 1; i <= 5; i++) {
      if (rating >= i) {
        html += '<span style="color:' + color + ';font-size:' + size + 'px;">&#9733;</span>';
      } else if (rating > i - 1) {
        var pct = Math.round((rating - (i - 1)) * 100);
        html += '<span style="display:inline-block;background:linear-gradient(90deg,' + color + ' ' + pct + '%,#e5e7eb ' + pct + '%);' +
                '-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;' +
                'font-size:' + size + 'px;">&#9733;</span>';
      } else {
        html += '<span style="color:#e5e7eb;font-size:' + size + 'px;">&#9733;</span>';
      }
    }
    container.innerHTML = html;
  }

  // 각 카드 별점 (정수)
  document.querySelectorAll('.rrCardStars').forEach(function (el) {
    renderStars(el, parseInt(el.dataset.rating), 16);
  });

  // 요약 별점 (소수점 평균)
  var summaryEl = document.getElementById('summaryStars');
  if (summaryEl) {
    renderStars(summaryEl, parseFloat('${avgRating}') || 0, 20);
  }
})();
</script>

<%@ include file="../common/footer.jsp"%>
