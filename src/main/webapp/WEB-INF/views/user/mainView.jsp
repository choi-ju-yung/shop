<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/main.css" />

<section>
   <!-- 배너 슬라이드 -->
   <div class="slideContainer">
      <div class="btnContainer">
         <ul class="slide" id="bannerSlide"></ul>
         <button class="prevBtn btn">&lt;</button>
         <button class="nextBtn btn">&gt;</button>
         <div class="slideDots" id="slideDots"></div>
      </div>
   </div>

   <!-- 카테고리 -->
   <div class="mainCategoryDiv">
      <a href="<%=request.getContextPath()%>/product/category">
         <div class="categoryLink"><div class="categoryBgAll"><ion-icon class="cateIcon" name="star"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">전체</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/product/category?name=패션의류">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="shirt"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">패션의류</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/product/category?name=패션잡화">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="sparkles"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">패션잡화</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/product/category?name=가전제품">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="construct"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">가전제품</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/product/category?name=PC%2F모바일">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="desktop"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">PC/모바일</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/product/category?name=가구%2F인테리어">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="bed"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">가구/인테리어</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/product/category?name=리빙%2F생활">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="leaf"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">리빙/생활</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/product/category?name=스포츠%2F레저">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="golf"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">스포츠/레저</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/product/category?name=도서%2F음반%2F문구">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="library"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">도서/음반/문구</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/product/category?name=차량%2F오토바이">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="speedometer"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">차량/오토바이</span></div></div>
      </a>
   </div>

   <!-- 최신 상품 -->
   <div class="mainSection">
      <div class="mainSectionHeader">
         <h2 class="mainSectionTitle">최신 상품</h2>
         <a href="<%=request.getContextPath()%>/product/category" class="mainMoreBtn">더보기 &rsaquo;</a>
      </div>
      <div class="mainProductGrid" id="mainProductList">
         <div class="mainSkeleton"></div>
         <div class="mainSkeleton"></div>
         <div class="mainSkeleton"></div>
         <div class="mainSkeleton"></div>
      </div>
   </div>
</section>

<script>
(function() {
    var ctx = '<%=request.getContextPath()%>';
    var isLoggedIn  = ${ not empty sessionScope.loginUser ? 'true' : 'false' };
    var loginUserNo = ${ not empty sessionScope.loginUser ? sessionScope.loginUser.userNo : 0 };

    $.ajax({
        url: ctx + '/product/list',
        type: 'GET',
        dataType: 'json',
        success: function(products) {
            var html = '';
            if (!products || products.length === 0) {
                html = '<p class="mainEmpty">등록된 상품이 없습니다.</p>';
            } else {
                products.forEach(function(p) {
                    var imgSrc = p.mainFilePath
                        ? ctx + p.mainFilePath
                        : ctx + '/images/common/hifiveLogo.png';
                    var detailUrl = ctx + '/product/' + p.productId;
                    var ts    = p.tradeStatus || 'SALE';
                    var price = p.price ? p.price.toLocaleString() + '원' : '가격 미정';
                    var isMyProduct = isLoggedIn && (p.userNo == loginUserNo);
                    var wishBtn = (isLoggedIn && !isMyProduct)
                        ? '<button class="mainWishBtn" data-product-id="' + p.productId + '" data-trade-status="' + ts + '" title="찜하기"><ion-icon name="heart-outline"></ion-icon></button>'
                        : '';
                    var badge = ts === 'SOLD'     ? '<span class="mainSoldDim">거래완료</span>'
                              : ts === 'RESERVED' ? '<span class="mainReservedBadge">예약중</span>'
                              : '<span class="mainSaleBadge">판매중</span>';
                    html +=
                        '<div class="mainCard">' +
                          wishBtn +
                          '<a href="' + detailUrl + '" class="mainCardLink">' +
                            '<div class="mainCardImg">' +
                              '<img src="' + imgSrc + '" alt="' + p.title + '"' +
                                   ' onerror="this.src=\'' + ctx + '/images/common/hifiveLogo.png\'">' +
                              badge +
                            '</div>' +
                            '<div class="mainCardBody">' +
                              '<p class="mainCardTitle">' + p.title + '</p>' +
                              '<p class="mainCardPrice">' + price + '</p>' +
                              '<div class="mainCardMeta">' +
                                '<span class="mainCardState">' + p.state + '</span>' +
                                '<span class="mainCardPlace"><ion-icon name="location-outline"></ion-icon>' + (p.place || '지역 미설정') + '</span>' +
                              '</div>' +
                            '</div>' +
                          '</a>' +
                        '</div>';
                });
            }
            $('#mainProductList').html(html);

            /* 찜 상태 초기화 */
            if (isLoggedIn) {
                document.querySelectorAll('.mainWishBtn').forEach(function(btn) {
                    $.ajax({
                        url: ctx + '/member/wish/status',
                        data: { productId: btn.dataset.productId },
                        success: function(res) { applyMainWish(btn, res.wished); }
                    });
                });
            }
        },
        error: function() {
            $('#mainProductList').html('<p class="mainEmpty">상품 목록을 불러오지 못했습니다.</p>');
        }
    });

    /* 찜 버튼 클릭 */
    $(document).on('click', '.mainWishBtn', function(e) {
        e.preventDefault();
        e.stopPropagation();
        if ($(this).data('trade-status') === 'SOLD') {
            alert('이미 판매된 상품입니다.');
            return;
        }
        var btn = this;
        $.ajax({
            url: ctx + '/member/wish/toggle',
            type: 'POST',
            data: { productId: btn.dataset.productId },
            success: function(res) { applyMainWish(btn, res.wished); },
            error: function() { alert('로그인이 필요합니다.'); }
        });
    });

    function applyMainWish(btn, wished) {
        var icon = btn.querySelector('ion-icon');
        if (wished) {
            icon.setAttribute('name', 'heart');
            btn.classList.add('mainWishBtn--active');
        } else {
            icon.setAttribute('name', 'heart-outline');
            btn.classList.remove('mainWishBtn--active');
        }
    }


})();
</script>

<script src="<%=request.getContextPath()%>/js/common/main.js"></script>
<%@ include file="../common/footer.jsp"%>
