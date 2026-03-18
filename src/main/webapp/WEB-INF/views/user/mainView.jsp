	<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/main.css" />

<section>
   <!-- 광고배너 -->
   <div class="slideContainer">
      <div class="btnContainer">
         <ul class="slide">
            <li><img src="https://media.bunjang.co.kr/images/nocrop/1003399005_w2058.jpg" alt="" /></li>
            <li><img src="https://media.bunjang.co.kr/images/nocrop/1006416046_w1197.jpg" alt="" /></li>
            <li><img src="https://media.bunjang.co.kr/images/nocrop/1006977703_w1197.jpg" alt="" /></li>
            <li><img src="https://media.bunjang.co.kr/images/nocrop/1007175998_w1197.jpg" alt="" /></li>
         </ul>
         <button class="prevBtn btn">&lt;</button>
         <button class="nextBtn btn">&gt;</button>
      </div>
   </div>

   <!-- 카테고리 -->
   <div class="mainCategoryDiv">
      <a href="<%=request.getContextPath()%>/user/category">
         <div class="categoryLink"><div class="categoryBgAll"><ion-icon class="cateIcon" name="star"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">전체</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/user/category?name=패션의류">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="shirt"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">패션의류</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/user/category?name=패션잡화">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="sparkles"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">패션잡화</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/user/category?name=가전제품">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="construct"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">가전제품</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/user/category?name=PC%2F모바일">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="desktop"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">PC/모바일</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/user/category?name=가구%2F인테리어">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="bed"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">가구/인테리어</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/user/category?name=리빙%2F생활">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="leaf"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">리빙/생활</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/user/category?name=스포츠%2F레저">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="golf"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">스포츠/레저</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/user/category?name=도서%2F음반%2F문구">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="library"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">도서/음반/문구</span></div></div>
      </a>
      <a href="<%=request.getContextPath()%>/user/category?name=차량%2F오토바이">
         <div class="categoryLink"><div class="categoryBg"><ion-icon class="cateIcon" name="speedometer"></ion-icon></div><div class="spanDiv"><span class="categoryTitle">차량/오토바이</span></div></div>
      </a>
   </div>

   <!-- 최신 상품 목록 (AJAX로 실시간 로드) -->
   <div class="popularProDiv">
      <div class="proTitleDiv">
         <h1 class="proTitle">최신 상품</h1>
         <a href="<%=request.getContextPath()%>/user/category" class="moreBtn">더보기</a>
      </div>
      <div class="productDiv" id="mainProductList">
         <p style="padding:20px;color:#999;">상품을 불러오는 중...</p>
      </div>
   </div>
</section>

<script>
(function() {
    var ctx = '<%=request.getContextPath()%>';

    $.ajax({
        url: ctx + '/user/mainProducts',
        type: 'GET',
        dataType: 'json',
        success: function(products) {
            var html = '';
            if (!products || products.length === 0) {
                html = '<p style="padding:20px;color:#999;">등록된 상품이 없습니다.</p>';
            } else {
                products.forEach(function(p) {
                    var imgSrc = p.mainFilePath
                        ? ctx + p.mainFilePath
                        : ctx + '/css/images/common/hifiveLogo.png';
                    var detailUrl = ctx + '/user/product/' + p.productId;
                    var stateLabel = (p.state === '미개봉') ? 'NEW ' + p.state : p.state;
                    var price = p.price ? p.price.toLocaleString() + '원' : '가격 미정';
                    html += '<div class="productAll">' +
                        '<div class="product">' +
                        '<div class="productImg">' +
                        '<a class="productLink" href="' + detailUrl + '">' +
                        '<img src="' + imgSrc + '" alt="' + p.title + '" onerror="this.src=\'' + ctx + '/css/images/common/hifiveLogo.png\'">' +
                        '</a>' +
                        '</div>' +
                        '<div class="proContent">' +
                        '<h4 class="contentMargin"><a href="' + detailUrl + '" class="aTag productTitle">' + p.title + '</a></h4>' +
                        '<div class="PriceNStatus">' +
                        '<h3 class="price">' + price + '</h3>' +
                        '<div class="statusBtnDiv"><span class="statusBtn">' + stateLabel + '</span></div>' +
                        '</div>' +
                        '</div>' +
                        '</div>' +
                        '</div>';
                });
            }
            $('#mainProductList').html(html);
        },
        error: function() {
            $('#mainProductList').html('<p style="padding:20px;color:#f00;">상품 목록을 불러오지 못했습니다.</p>');
        }
    });
})();
</script>

<script src="<%=request.getContextPath()%>/js/common/main.js"></script>
<%@ include file="../common/footer.jsp"%>