<%@page import="com.example.demo.user.vo.UserVO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
   pageEncoding="UTF-8"%>
   <%@ taglib prefix="c" uri="jakarta.tags.core"%>
  <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
<%-- <%@page import="com.semi.category.model.vo.Category"%>
<%@page import="java.util.List"%> --%>


<!DOCTYPE html>
<html>
<head>
<script>
   //로그인한 아이디 sessionStorage에 저장하자..ㅋㅋㅋ
  <%--  var contextPath = "<%=request.getContextPath()%>";
   sessionStorage.setItem("loginId",'<%=loginMember!=null?loginMember.getId():""%>'); --%>
</script>
<meta charset="UTF-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<meta name="ctx" content="<%=request.getContextPath()%>" />
<!-- css 파일 -->
<link rel="stylesheet"
   href="<%=request.getContextPath()%>/css/default.css" />
<link rel="icon"
   href="<%=request.getContextPath()%>/images/common/fivicon.png"
   type="image/x-icon" />
<!-- js 파일 -->
<script type="module"
   src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
   
<script nomodule
   src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
<%-- <script src="<%=request.getContextPath()%>/js/jquery-3.7.0.min.js"></script> --%>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<!--  -->
<title>중고 거래 HiFive</title>
</head>
<body>

	<header>
		<div id="headerContainer">
			<div id="fixedContainer">
				
				<c:if test="${empty sessionScope.loginUser}">
				<div class="loginSerivce">
					<a href="<%=request.getContextPath()%>/login" id="login">로그인</a>
					<a href="<%=request.getContextPath()%>/regist/nomalregist" id="enroll">회원가입</a>
					<a
						href="<%=request.getContextPath()%>/board/list?notice=N"
						id="service">고객센터</a>
				</div>
				</c:if>
				<c:if test="${not empty sessionScope.loginUser}">
				<div class="loginSerivce">
				<%-- <%if(loginMember.getAuth().equals("M")){%>
					<a href="<%=request.getContextPath()%>/adminMode.do">관리자모드</a>
					<%} %> --%>
					<c:if test="${sessionScope.loginUser.role == 'ROLE_ADMIN'}">
						<a href="<%=request.getContextPath()%>/admin/adminMode">관리자모드</a>
					</c:if> 
					<a href="#"
						onclick="location.replace('<%=request.getContextPath()%>/logout')"
						id="logout">로그아웃</a> <a
						href="<%=request.getContextPath()%>/board/list?notice=N"
						id="service">고객센터</a>
				</div>
 				</c:if>
   
            <div class="headerMain">
               <div class="logo">
                  <a href="<%=request.getContextPath()%>/"> <img
                     src="<%=request.getContextPath()%>/images/common/logo.svg"
                     alt="" />
                  </a>
               </div>
               <div class="searchBar">
                  <div class="searchDetail">
                     <form id="searchForm" class="form" action="<%=request.getContextPath()%>/product/search" method="get">
                        <input name="keyword" id="searchInput" maxlength="50" type="text"
                           placeholder="상품명, #키워드 검색" onfocus="this.placeholder = ''"
                        onblur="this.placeholder = '상품명, #키워드 검색'">
                        <button type="reset" id="resetBtn">
                     <ion-icon name="close"></ion-icon>
                     </button>
                     </form>

                     <button type="submit" form="searchForm" id="submitBtn">
                        <img
                           src="<%=request.getContextPath()%>/images/common/magnifier.png"
                           alt="" />
                     </button>
                  </div>

                  <div class="searchpage">

                     <div class="searchbody">
                        <hr>
                        <div class="recentSearch">
                           <div class="allDelete off">
                              <span id="recentHead">최근 검색어</span> <span id="allDeleteBtn">모두
                                 지우기</span>
                           </div>
                           <p class="recentText"></p>
                           <ul id="recentList">

                           </ul>
                        </div>
                     </div>               
                  </div>
               </div>
               <div class="memberIcon">
                  <a href="<%=request.getContextPath()%>/member/sell"> <ion-icon
                        name="storefront-outline" class="storeIcon"></ion-icon> <span>
                        판매하기</span>
                  </a>
<%--                   <%
                  if (loginMember != null) {
                  %> --%>
                  <a
                     href="<%=request.getContextPath()%>/member/mypage">
                     <ion-icon name="person-outline" class="myIcon"></ion-icon> 내정보
                  </a> <a href="<%=request.getContextPath()%>/myPage/wishList.do"> <ion-icon name="heart-outline" class="heartIcon"></ion-icon>
                     찜한상품
                  </a>
                  <a href="<%=request.getContextPath()%>/member/chat"> <ion-icon name="mail-outline" class="heartIconr"></ion-icon>
                     채팅
                  </a>
                  <a href="<%=request.getContextPath()%>/"> <ion-icon name="mail-outline" class="heartIconr"></ion-icon>
                     알림 
                  </a>
                  <div id="toast-container"></div>
<%--                   <%
                  } else {
                  %>
                  <a href="<%=request.getContextPath()%>/productRegist.do"> <ion-icon
                        name="person-outline" class="myIcon"></ion-icon> 내정보
                  </a> <a href="<%=request.getContextPath()%>/productRegist.do"> <ion-icon
                        name="heart-outline" class="heartIcon"></ion-icon> 찜한상품
                  </a>
                  <%
                  }
                  %> --%>
               </div>
            </div>
            <div class="categoryNrank">
                <input type="checkbox" id="menuIcon" /> <label for="menuIcon"
                  class="headercategorybtn"> <span></span> <span></span> <span></span>
               </label>
               <div id="menuList">
                  <ul>
                   </ul>
               </div> 
               
               
               <p>카테고리</p>
               
               <div id="printSearch">
              <div id="rankSearch">
                <button>버튼</button>
              </div>
         
            </div>
             
            </div>
               
         </div>
         <hr width="1280px" color="#eeeeee" noshade />
             <div id="rankAllSearch">
            <div>
               <p>인기검색어 순</p><button>버튼</button>
               </div>
              </div>
      </div>

      <div id="itemBox">
         <div id="recentProduct">
            <p>최근본상품</p>
            <div class="rpCount">0</div>
            <div id="recently" ><a><img alt="" src=""></a></div>
         </div>
      </div>
   </header>
   <script>
  
 /* ---------------------------------------------------------  */	
   
   let socket = new SockJS('/ws');
   let stompClient = Stomp.over(socket);
   let userNo = '${sessionScope.loginUser.userNo}';

    stompClient.connect({}, function () {
       stompClient.subscribe("/user/queue/notify", function (message) {
           const data = JSON.parse(message.body);
           //increaseNotificationCount();
           createToast(data.notiMessage);
       });
   });

   

   function increaseNotificationCount() {
       const countEl = document.getElementById("notification-count");
       let count = parseInt(countEl.innerText) || 0;
       countEl.innerText = count + 1;
   }

   function createToast(message) {
       /* const container = document.getElementById("toast-container");
       const toast = document.createElement("div");
       toast.className = "toast";
       toast.innerHTML = message;
       toast.style.cssText = `
           background: #333; color: #fff; padding: 10px 20px;
           margin-top: 10px; border-radius: 5px;
           box-shadow: 0 4px 6px rgba(0,0,0,0.2);
           animation: fadein 0.3s, fadeout 0.5s 4.5s;
    	   white-space: pre-wrap;
       `;
       container.appendChild(toast);
       setTimeout(() => container.removeChild(toast), 4000); */
	   const notificationArea = document.querySelector(".memberIcon a:last-child"); // 알림 버튼 선택
	    const rect = notificationArea.getBoundingClientRect();
	    const toast = document.createElement("div");
	    toast.className = "toast";
	    toast.innerHTML = message;
	    toast.style.position = "fixed";
	    toast.style.top = (rect.top + rect.height + 10) + "px";
	    toast.style.left = rect.left + "px";
	    toast.style.zIndex = "1000";
	    // ... 나머지 스타일
	    document.body.appendChild(toast);
	    setTimeout(() => toast.remove(), 4000);
   }
/* ---------------------------------------------------------  */	
   
function changePage(pageNo) {
    $.ajax({
        url: "<%=request.getContextPath()%>/categoryproductlist.do",
        type: "GET",
        data: {
            'cPage': pageNo,
            'numPerpage': 32
        },
        dataType: "html",
        success: function(data) {
            $("section").html(data);
        }
    });
}



// 페이지 로딩 후 헤더 카테고리 메뉴 빌드
$(function() { HeaderCategoryMenu(); });

function HeaderCategoryMenu() {
    $.ajax({
        url: "<%=request.getContextPath()%>/product/categories",
        dataType: 'json',
        success: function(data) {
            var ctx = "<%=request.getContextPath()%>";
            var $ul = $("#menuList>ul");
            $ul.html("<li><a href='" + ctx + "/product/category' id='category0'>전체</a></li>");

            // 카테고리별 그룹핑 후 메뉴 생성
            var categories = {};
            data.forEach(function(row) {
                var cat = row['CATEGORY_NAME'] || row['category_name'];
                var sub = row['SUB_CATEGORY_NAME'] || row['sub_category_name'];
                if (!categories[cat]) categories[cat] = [];
                if (sub) categories[cat].push(sub);
            });

            var idx = 1;
            Object.keys(categories).forEach(function(catName) {
                var $li = $("<li>").addClass("has-sub");
                var $a = $("<a>").attr("href", ctx + "/product/category?name=" + encodeURIComponent(catName))
                                 .attr("id", "category" + idx)
                                 .text(catName);
                $li.append($a);

                // 서브카테고리 드롭다운 생성
                var subs = categories[catName];
                if (subs && subs.length > 0) {
                    var $subUl = $("<ul>").addClass("sub-menu");
                    subs.forEach(function(subName) {
                        var $subLi = $("<li>");
                        var $subA = $("<a>").attr("href", ctx + "/product/category?name=" + encodeURIComponent(subName))
                                           .text(subName);
                        $subLi.append($subA);
                        $subUl.append($subLi);
                    });
                    $li.append($subUl);
                }

                $ul.append($li);
                idx++;
            });
        },
        error: function() {
            // 카테고리 로드 실패 시 조용히 무시
        }
    });
}
/* function makeCategoryHeader(name, index) {
    const $li = $("<li>");
    const $a = $("<a>").attr("id", "category" + (index + 1)).data('categoryname', "CATEGORY_NAME = '" + name + "'").text(name);

    $a.click(function() {
        const conditions = {};
        conditions['categoryname'] = $(this).data('categoryname');
        console.log(conditions);
        getselectproduct(conditions);
    });

    $li.append($a);
    $("#menuList>ul").append($li);
} */

<%-- function getselectproduct(conditions) {
    console.log(conditions);
    $.ajax({
        url: "<%=request.getContextPath()%>/test",
        dataType: 'html',
        data: conditions,
        success: function(data) {
            $("section").html(data);
        }
    });
} --%>
/* function makeCategoryHeader(name, index) {
   
    const $li = $("<li>");
    const $a = $("<a>").attr("id", "category" + (index + 1)).text(name).attr("onclick", "searchCategory('" + name + "');");
    $li.append($a);
    $("#menuList>ul").append($li);
} */
function makeCategoryHeader(name, index) {
	categoryname = "CATEGORY_NAME = '" + name + "'";
    const $li = $("<li>");
    const $a = $("<a>").attr("href", "<%=request.getContextPath()%>/getproduct.do?categoryname="+categoryname).attr("id", "category" + (index + 1)).text(name);
<%--     const $categoryName = $("<span>").text(categoryname + " " + '(<%=request.getAttribute("totalData")%>)' + " ");
 --%>    <%-- const $a = $("<a>").attr("href", "<%=request.getContextPath()%>/headersearchcategory.do?categoryname="+name).attr("id", "category" + (index + 1)).text(name); --%> 
    $li.append($a);
	$("#menuList>ul").append($li);
}
function makeCatetorySub(subcateList, index) {
    const $div=$("<div>").attr({"id":"sideMenu-category"+(index+1),"class":"sideMenu"});
    const $ul=$("<ul>");
    subcateList.forEach(sub=>{
    	subcategoryname = "SUBCATEGORY_NAME = '" + sub.subCategory.subcategoryName +"'";
    	const $a = $("<a>").attr("href", "<%=request.getContextPath()%>/getproduct.do?subcategroyname="+subcategoryname).text(sub.subCategory.subcategoryName);
<%--            const $a = $("<a>").attr("href", "<%=request.getContextPath()%>/searchheadersubcategory.do?subcategroyname="+sub.subCategory.subcategoryName).text(sub.subCategory.subcategoryName);
 --%>           const $li = $("<li>").append($a);
           $ul.append($li);
    });
$div.html($ul);
$("div#menuList").after($div);

}

     /* function makeCatetorySub(subcateList, index) {
       const $div=$("<div>").attr({"id":"sideMenu-category"+(index+1),"class":"sideMenu"});
       const $ul=$("<ul>");
       subcateList.forEach(sub=>{
              const $a = $("<a href='javascript:void(0);'>").text(sub.subCategory.subcategoryName).attr("onclick", "searchsubcategory('" + sub.subCategory.subcategoryName + "');");
              const $li = $("<li>").append($a);
              $ul.append($li);
       });
       $div.html($ul);
       $("div#menuList").after($div); */

     
     <%-- const subcategoryName = sub.subCategory.subcategoryName;
      const encodedSubcategoryName = encodeURIComponent(subcategoryName);
      const href = '<%= request.getContextPath() %>/headersearchcategory.do?subcategoryname=' + encodedSubcategoryName;
      const $a = $("<a>").attr("href", href).text(subcategoryName); --%>
</script>
   <script src="<%=request.getContextPath()%>/js/common/header.js"></script>