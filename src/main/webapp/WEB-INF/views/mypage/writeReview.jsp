<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../common/header.jsp"%>
<%@ include file="../mypage/myPageCategory.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/mypage/writeReview.css"/>

<div class="myPageContent">
  <div class="rvWrap">

    <div class="rvHeader">
      <div class="rvHeaderIcon"><ion-icon name="star"></ion-icon></div>
      <div>
        <h2 class="rvHeaderTitle">거래 후기 작성</h2>
        <p class="rvHeaderSub">판매자와의 거래 경험을 공유해주세요</p>
      </div>
    </div>

    <div class="rvProductCard">
      <div class="rvProductImgWrap">
        <c:choose>
          <c:when test="${not empty product.IMG_PATH}">
            <img class="rvProductImg"
                 src="<%=request.getContextPath()%>${product.IMG_PATH}"
                 onerror="this.src='<%=request.getContextPath()%>/images/common/hifiveLogo.png'"
                 alt="상품이미지">
          </c:when>
          <c:otherwise>
            <div class="rvProductImgPlaceholder"><ion-icon name="cube-outline"></ion-icon></div>
          </c:otherwise>
        </c:choose>
        <span class="rvSoldBadge">거래완료</span>
      </div>
      <div class="rvProductInfo">
        <p class="rvProductTitle"><c:out value="${product.PRODUCT_TITLE}"/></p>
        <p class="rvProductPrice"><fmt:formatNumber value="${product.PRODUCT_PRICE}" pattern="#,###"/>원</p>
        <p class="rvProductSeller">
          <ion-icon name="storefront-outline"></ion-icon>
          <c:out value="${product.SELLER_NAME}"/> 님과 거래
        </p>
      </div>
    </div>

    <form id="reviewForm" class="rvCard"
          action="<%=request.getContextPath()%>/member/review/write" method="post">
      <input type="hidden" name="productId"  value="${product.PRODUCT_ID}">
      <input type="hidden" name="revieweeNo" value="${product.SELLER_NO}">
      <input type="hidden" name="rating"     id="ratingInput" value="0">

      <%-- 별점 --%>
      <div class="rvField">
        <label class="rvLabel"><ion-icon name="star"></ion-icon> 별점 선택</label>
        <div class="rvStarSection">
          <div class="rvStars" id="starGroup">
            <span class="rvStar" data-v="1">&#9733;</span>
            <span class="rvStar" data-v="2">&#9733;</span>
            <span class="rvStar" data-v="3">&#9733;</span>
            <span class="rvStar" data-v="4">&#9733;</span>
            <span class="rvStar" data-v="5">&#9733;</span>
          </div>
          <div class="rvRatingDisplay">
            <span class="rvRatingNum"  id="ratingNum">-</span>
            <span class="rvRatingLabel" id="ratingLabel">별점을 선택해주세요</span>
          </div>
        </div>
        <div class="rvMoodRow" id="moodRow" style="display:none;">
          <span class="rvMoodChip" id="moodChip"></span>
        </div>
      </div>

      <div class="rvDivider"></div>

      <%-- 후기 내용 --%>
      <div class="rvField">
        <label class="rvLabel">
          <ion-icon name="chatbubble-ellipses-outline"></ion-icon>
          후기 내용 <span class="rvOptional">(선택)</span>
        </label>
        <div class="rvTextareaWrap">
          <textarea name="content" id="rvContent" class="rvTextarea"
                    placeholder="거래 경험을 자유롭게 남겨주세요 (최대 500자)"
                    maxlength="500"></textarea>
          <div class="rvCharBadge"><span id="charCount">0</span>/500</div>
        </div>
      </div>

      <p class="rvResultMsg" id="resultMsg"></p>

      <button type="submit" class="rvSubmitBtn rvSubmitBtn--off" id="rvSubmitBtn">
        <ion-icon name="checkmark-circle-outline"></ion-icon> 후기 등록하기
      </button>
    </form>

  </div>
</div>

</section>

<script>
$(function() {
  var LABELS = ['', '별로예요', '그저 그래요', '보통이에요', '좋아요', '최고예요!'];
  var MOODS  = ['', '😞 아쉬운 거래였어요', '😐 그냥 무난했어요', '🙂 나쁘지 않았어요', '😊 좋은 거래였어요', '🤩 완벽한 거래였어요!'];
  var COLORS = ['', '#ef4444', '#f97316', '#eab308', '#22c55e', '#20c997'];
  var selectedRating = 0;

  function paintStars(n) {
    $('.rvStar').each(function() {
      var v   = parseInt($(this).data('v'));
      var on  = v <= n;
      var col = COLORS[selectedRating] || '#eab308';
      $(this).css({
        color: on ? col : '#e5e7eb',
        textShadow: on ? ('0 0 8px ' + col + '60') : 'none',
        transform: on ? 'scale(1.1)' : 'scale(1)'
      });
    });
  }

  /* ── 별점 클릭 ── */
  $(document).on('click', '.rvStar', function() {
    selectedRating = parseInt($(this).data('v'));
    $('#ratingInput').val(selectedRating);
    $('#ratingNum').text(selectedRating + '점').css('color', COLORS[selectedRating]);
    $('#ratingLabel').text(LABELS[selectedRating]).css('color', COLORS[selectedRating]);
    $('#moodChip').text(MOODS[selectedRating]).css({
      background:  COLORS[selectedRating] + '18',
      color:       COLORS[selectedRating],
      borderColor: COLORS[selectedRating] + '55'
    });
    $('#moodRow').show();
    $('#rvSubmitBtn').removeClass('rvSubmitBtn--off');
    paintStars(selectedRating);
  });

  $(document).on('mouseover', '.rvStar', function() { paintStars(parseInt($(this).data('v'))); });
  $(document).on('mouseout',  '.rvStar', function() { paintStars(selectedRating); });

  /* ── 글자 수 카운트 ── */
  $('#rvContent').on('input', function() {
    var n = this.value.length;
    $('#charCount').text(n);
    $('.rvCharBadge').css('color', n > 450 ? '#ef4444' : '#9ca3af');
  });

  /* ── 폼 제출 검증 ── */
  $('#reviewForm').on('submit', function(e) {
    if (selectedRating === 0) {
      e.preventDefault();
      $('#resultMsg').text('별점을 선택해주세요.').css('color', '#dc2626');
      $('#starGroup').addClass('rvShake');
      setTimeout(function() { $('#starGroup').removeClass('rvShake'); }, 400);
      return;
    }
    $('#rvSubmitBtn').addClass('rvSubmitBtn--off')
                   .html('<ion-icon name="hourglass-outline"></ion-icon> 등록 중...');
  });
});
</script>

<%@ include file="../common/footer.jsp"%>
