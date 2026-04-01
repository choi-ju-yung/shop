<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/product/searchResult.css" />

<%-- 검색 파라미터를 data attribute로 안전하게 전달 --%>
<div id="srData"
     data-keyword="${keyword}"
     data-category="${categoryName}"
     style="display:none;"></div>

<section>
  <div class="srContainer">

    <%-- ===================== 좌측 사이드바 ===================== --%>
    <aside class="srSidebar">

      <div class="filterBox">
        <h3 class="filterBoxTitle">카테고리</h3>
        <ul class="cateFilterList" id="cateFilterList">
          <li class="cateItem">
            <a href="<%=request.getContextPath()%>/product/category"
               class="cateLink mainCate <c:if test="${categoryName == '전체' || (empty categoryName && empty keyword)}">active</c:if>">
              전체
            </a>
          </li>
          <%-- AJAX로 나머지 카테고리 로드 --%>
        </ul>
      </div>

      <div class="filterBox">
        <h3 class="filterBoxTitle">가격대</h3>
        <ul class="optionList">
          <li><label class="optionLabel"><input type="radio" name="priceFilter" value="all" checked><span>전체</span></label></li>
          <li><label class="optionLabel"><input type="radio" name="priceFilter" value="0-50000"><span>5만원 이하</span></label></li>
          <li><label class="optionLabel"><input type="radio" name="priceFilter" value="50000-100000"><span>5만 ~ 10만원</span></label></li>
          <li><label class="optionLabel"><input type="radio" name="priceFilter" value="100000-300000"><span>10만 ~ 30만원</span></label></li>
          <li><label class="optionLabel"><input type="radio" name="priceFilter" value="300000-"><span>30만원 이상</span></label></li>
        </ul>
      </div>

      <div class="filterBox">
        <h3 class="filterBoxTitle">상품 상태</h3>
        <ul class="optionList">
          <li><label class="optionLabel"><input type="checkbox" class="stateCheck" value="미개봉"><span>미개봉</span></label></li>
          <li><label class="optionLabel"><input type="checkbox" class="stateCheck" value="거의새것"><span>거의새것</span></label></li>
          <li><label class="optionLabel"><input type="checkbox" class="stateCheck" value="사용감 있음"><span>사용감 있음</span></label></li>
        </ul>
      </div>

    </aside>

    <%-- ===================== 우측 메인 영역 ===================== --%>
    <main class="srMain">

      <%-- 검색 정보 바 --%>
      <div class="srInfoBar">
        <div class="srLabel">
          <c:choose>
            <c:when test="${not empty keyword}">
              <span class="srKeyword">"<c:out value="${keyword}"/>"</span> 검색결과
            </c:when>
            <c:when test="${not empty categoryName}">
              <span class="srKeyword"><c:out value="${categoryName}"/></span>
            </c:when>
          </c:choose>
          <span class="srCount">총 <em id="resultCount">${products.size()}</em>개</span>
        </div>
        <div class="srSortBar">
          <button class="srSortBtn active" data-sort="latest">최신순</button>
          <button class="srSortBtn" data-sort="price-asc">낮은가격순</button>
          <button class="srSortBtn" data-sort="price-desc">높은가격순</button>
        </div>
      </div>

      <%-- 상품 목록 --%>
      <div class="srProductGrid" id="productList">
        <c:choose>
          <c:when test="${empty products}">
            <div class="srNoResult">
              <ion-icon name="search-outline"></ion-icon>
              <p>검색 결과가 없습니다.</p>
              <a href="<%=request.getContextPath()%>/product/category" class="srNoResultBtn">전체 상품 보기</a>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="p" items="${products}">
              <div class="srProductCard"
                   data-price="${p.price}"
                   data-state="${p.state}"
                   data-id="${p.productId}">
                <a href="<%=request.getContextPath()%>/product/${p.productId}" class="srProductLink">
                  <div class="srProductImg">
                    <c:choose>
                      <c:when test="${not empty p.mainFilePath}">
                        <img src="<%=request.getContextPath()%>${p.mainFilePath}"
                             alt="<c:out value='${p.title}'/>"
                             onerror="this.src='<%=request.getContextPath()%>/images/common/hifiveLogo.png'">
                      </c:when>
                      <c:otherwise>
                        <img src="<%=request.getContextPath()%>/images/common/hifiveLogo.png"
                             alt="<c:out value='${p.title}'/>">
                      </c:otherwise>
                    </c:choose>
                    <c:if test="${p.state == '미개봉'}">
                      <span class="srNewBadge">NEW</span>
                    </c:if>
                  </div>
                  <div class="srProductInfo">
                    <p class="srProductTitle"><c:out value="${p.title}"/></p>
                    <div class="srPriceRow">
                      <strong class="srPrice"><fmt:formatNumber value="${p.price}" pattern="#,###"/>원</strong>
                      <span class="srStateBadge">${p.state}</span>
                    </div>
                    <p class="srPlace">
                      <ion-icon name="location-outline"></ion-icon>
                      <c:out value="${not empty p.place ? p.place : '지역 미설정'}"/>
                    </p>
                  </div>
                </a>
              </div>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>

    </main>
  </div>
</section>

<script>
(function () {
  var ctx = '<%=request.getContextPath()%>';
  var srData = document.getElementById('srData');
  var currentKeyword = srData.dataset.keyword || '';
  var currentCate = srData.dataset.category || '';

  /* ── 카테고리 사이드바 로드 ── */
  $.ajax({
    url: ctx + '/product/categories',
    type: 'GET',
    dataType: 'json',
    success: function (data) {
      var catMap = {};
      var catOrder = [];
      data.forEach(function (item) {
        var cname = item.CATEGORY_NAME;
        if (!catMap[cname]) { catMap[cname] = []; catOrder.push(cname); }
        if (item.SUB_CATEGORY_NAME) catMap[cname].push(item.SUB_CATEGORY_NAME);
      });

      var html = '';
      catOrder.forEach(function (cname) {
        var isMainActive = (currentCate === cname) ? ' active' : '';
        var isOpen = (currentCate === cname || catMap[cname].indexOf(currentCate) !== -1);
        html += '<li class="cateItem">';
        html += '<a href="' + ctx + '/product/category?name=' + encodeURIComponent(cname) + '"'
              + ' class="cateLink mainCate' + isMainActive + '">' + cname + '</a>';
        if (catMap[cname].length > 0) {
          html += '<ul class="subCateList' + (isOpen ? ' open' : '') + '">';
          catMap[cname].forEach(function (sname) {
            var isSubActive = (currentCate === sname) ? ' active' : '';
            html += '<li><a href="' + ctx + '/product/category?name=' + encodeURIComponent(sname) + '"'
                  + ' class="cateLink subCate' + isSubActive + '">' + sname + '</a></li>';
          });
          html += '</ul>';
        }
        html += '</li>';
      });
      $('#cateFilterList').append(html);
    }
  });

  /* ── 정렬 ── */
  $(document).on('click', '.srSortBtn', function () {
    $('.srSortBtn').removeClass('active');
    $(this).addClass('active');
    applyFilter();
  });

  /* ── 가격 필터 ── */
  $(document).on('change', 'input[name="priceFilter"]', function () {
    applyFilter();
  });

  /* ── 상태 필터 ── */
  $(document).on('change', '.stateCheck', function () {
    applyFilter();
  });

  function applyFilter() {
    var sort = $('.srSortBtn.active').data('sort') || 'latest';
    var priceVal = $('input[name="priceFilter"]:checked').val();
    var selectedStates = [];
    $('.stateCheck:checked').each(function () { selectedStates.push($(this).val()); });

    var $grid = $('#productList');
    var cards = $grid.find('.srProductCard').toArray();
    var visible = 0;

    cards.forEach(function (card) {
      var $c = $(card);
      var price = parseInt($c.data('price')) || 0;
      var state = ($c.data('state') || '').toString();

      /* 가격 범위 */
      var priceOk = true;
      if (priceVal && priceVal !== 'all') {
        var parts = priceVal.split('-');
        var min = parseInt(parts[0]) || 0;
        var max = parts[1] !== '' ? parseInt(parts[1]) : Infinity;
        priceOk = (price >= min && price <= max);
      }

      /* 상태 */
      var stateOk = selectedStates.length === 0 || selectedStates.indexOf(state) !== -1;

      if (priceOk && stateOk) { $c.show(); visible++; } else { $c.hide(); }
    });

    /* 정렬 (보이는 카드 기준) */
    var visible_cards = $grid.find('.srProductCard:visible').toArray();
    visible_cards.sort(function (a, b) {
      var $a = $(a), $b = $(b);
      if (sort === 'price-asc')  return parseInt($a.data('price')) - parseInt($b.data('price'));
      if (sort === 'price-desc') return parseInt($b.data('price')) - parseInt($a.data('price'));
      /* latest: PRODUCT_ID DESC (sequence 기반 varchar → 길이 우선, 같으면 사전순 역순) */
      var ia = $a.data('id') + '', ib = $b.data('id') + '';
      return ib.length !== ia.length ? ib.length - ia.length : ib.localeCompare(ia);
    });
    visible_cards.forEach(function (c) { $grid.append(c); });

    $('#resultCount').text(visible);
  }

})();
</script>

<%@ include file="../common/footer.jsp"%>
