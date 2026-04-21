<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../common/header.jsp"%>
<%@ include file="../mypage/myPageCategory.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/mypage/wishList.css" />
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/common/pagination.css" />

<div class="wishPageWrap">
  <h2 class="wishPageTitle">
    <ion-icon name="heart"></ion-icon>
    찜한 상품
    <span class="wishCount">(${wishList.size()}개)</span>
  </h2>

  <c:choose>
    <c:when test="${empty wishList}">
      <div class="wishEmpty">
        <ion-icon name="heart-dislike-outline"></ion-icon>
        <p>찜한 상품이 없습니다.</p>
        <a href="<%=request.getContextPath()%>/product/category" class="wishEmptyBtn">상품 둘러보기</a>
      </div>
    </c:when>
    <c:otherwise>
      <c:set var="pageBaseUrl" value="?"/>
      <div class="wishGrid" id="wishGrid">
        <c:forEach var="w" items="${wishList}">
          <div class="wishCard" id="wishCard-${w.productId}">

            <%-- 찜 취소 버튼 --%>
            <button class="wishRemoveBtn"
                    data-product-id="${w.productId}"
                    title="찜 취소">
              <ion-icon name="heart"></ion-icon>
            </button>

            <%-- 상품 링크 --%>
            <a href="<%=request.getContextPath()%>/product/${w.productId}" class="wishCardLink">
              <div class="wishCardImg">
                <c:choose>
                  <c:when test="${not empty w.mainFilePath}">
                    <img src="<%=request.getContextPath()%>${w.mainFilePath}"
                         alt="<c:out value='${w.productTitle}'/>"
                         onerror="this.src='<%=request.getContextPath()%>/images/common/hifiveLogo.png'">
                  </c:when>
                  <c:otherwise>
                    <img src="<%=request.getContextPath()%>/images/common/hifiveLogo.png"
                         alt="이미지 없음">
                  </c:otherwise>
                </c:choose>
              </div>
              <div class="wishCardInfo">
                <p class="wishCardTitle"><c:out value="${w.productTitle}"/></p>
                <p class="wishCardPrice"><fmt:formatNumber value="${w.productPrice}" pattern="#,###"/>원</p>
                <div class="wishCardMeta">
                  <span class="wishCardState"><c:out value="${w.productState}"/></span>
                  <span><c:out value="${not empty w.productPlace ? w.productPlace : '지역 미설정'}"/></span>
                </div>
                <p class="wishCardSeller"><c:out value="${w.sellerName}"/> 판매</p>
              </div>
            </a>
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
  var ctx = '<%=request.getContextPath()%>';

  /* ── 찜 취소 ── */
  document.querySelectorAll('.wishRemoveBtn').forEach(function (btn) {
    btn.addEventListener('click', function (e) {
      e.preventDefault();
      var productId = btn.dataset.productId;
      if (!confirm('찜을 취소하시겠습니까?')) return;

      $.ajax({
        url: ctx + '/member/wish/toggle',
        type: 'POST',
        data: { productId: productId },
        success: function (res) {
          if (!res.wished) {
            var card = document.getElementById('wishCard-' + productId);
            card.style.transition = 'opacity 0.3s';
            card.style.opacity = '0';
            setTimeout(function () {
              card.remove();
              updateCount();
            }, 300);
          }
        },
        error: function () {
          alert('처리 중 오류가 발생했습니다.');
        }
      });
    });
  });

  function updateCount() {
    var remaining = document.querySelectorAll('.wishCard').length;
    var countEl = document.querySelector('.wishCount');
    if (countEl) countEl.textContent = '(' + remaining + '개)';

    if (remaining === 0) {
      document.getElementById('wishGrid').outerHTML =
        '<div class="wishEmpty">' +
        '<ion-icon name="heart-dislike-outline"></ion-icon>' +
        '<p>찜한 상품이 없습니다.</p>' +
        '<a href="' + ctx + '/product/category" class="wishEmptyBtn">상품 둘러보기</a>' +
        '</div>';
    }
  }
})();
</script>

<%@ include file="../common/footer.jsp"%>
