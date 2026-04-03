<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/product/productregist.css" />
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<%@ include file="../common/header.jsp"%>

<div class="regist-wrapper">
    <div class="regist-card">

        <!-- 헤더 -->
        <div class="regist-header">
            <h2>상품 등록</h2>
            <p class="required-notice"><span class="badge-required">필수</span> 표시는 필수 입력 항목입니다.</p>
        </div>

        <!-- 상품 이미지 -->
        <div class="form-section">
            <div class="form-label">
                <span class="label-text">상품 이미지</span>
                <span class="badge-required">필수</span>
            </div>
            <div class="form-content">
                <div class="image-upload-area">
                    <img src="<%=request.getContextPath()%>/images/productregist/imgregist.png"
                         class="upload" width="110" height="110">
                    <input type="file" id="inputFile" class="real-upload" accept="image/*" required multiple style="display:none;">
                    <p class="upload-hint">클릭하여 이미지 추가 <span class="imgCount">(0/10)</span></p>
                </div>
                <ul class="image-preview"></ul>
                <div class="image-guide">
                    <p>• 이미지는 등록 시 정사각형으로 잘려서 등록됩니다.</p>
                    <p>• 이미지를 드래그하여 순서를 변경할 수 있습니다.</p>
                    <p>• 이미지를 클릭하면 확대해서 볼 수 있습니다.</p>
                    <p>• 이미지 우상단의 X 버튼을 클릭하면 삭제됩니다.</p>
                    <p>• 개당 최대 10MB, 최대 10장까지 등록 가능합니다.</p>
                </div>
            </div>
        </div>

        <div class="divider"></div>

        <!-- 제목 -->
        <div class="form-section">
            <div class="form-label">
                <span class="label-text">제목</span>
                <span class="badge-required">필수</span>
            </div>
            <div class="form-content">
                <div class="input-wrap">
                    <input type="text" placeholder="상품 제목을 입력하세요" class="inputTitle form-input" name="title">
                    <span class="char-count countTitle">0/20</span>
                </div>
                <span id="spanTitle" class="error-msg"></span>
            </div>
        </div>

        <div class="divider"></div>

        <!-- 카테고리 -->
        <div class="form-section">
            <div class="form-label">
                <span class="label-text">카테고리</span>
                <span class="badge-required">필수</span>
            </div>
            <div class="form-content">
                <form name="frm1" style="display:flex; gap:12px;">
                    <select class="mainCate form-select" onchange="chageSubCate(this.value);">
                        <c:forEach var="category" items="${categorys}">
                            <option value="${category.categoryName}">${category.categoryName}</option>
                        </c:forEach>
                    </select>
                    <select class="middleCate form-select" name="subCate"></select>
                </form>
            </div>
        </div>

        <div class="divider"></div>

        <!-- 거래지역 -->
        <div class="form-section">
            <div class="form-label">
                <span class="label-text">거래지역</span>
                <span class="badge-required">필수</span>
            </div>
            <div class="form-content">
                <div class="place-wrap">
                    <button type="button" class="btn-address" id="sample6Id" onclick="sample6_execDaumPostcode()">주소 검색</button>
                    <input type="text" id="sample6_address" placeholder="주소를 검색해주세요" name="place" readonly class="form-input">
                </div>
                <input type="hidden" id="sample6_postcode">
                <input type="hidden" id="sample6_detailAddress">
                <input type="hidden" id="sample6_extraAddress">
                <span id="spanPlace" class="error-msg"></span>
            </div>
        </div>

        <div class="divider"></div>

        <!-- 상태 -->
        <div class="form-section">
            <div class="form-label">
                <span class="label-text">상품 상태</span>
                <span class="badge-required">필수</span>
            </div>
            <div class="form-content">
                <div class="radio-group">
                    <label class="radio-label">
                        <input type="radio" name="state" value="미개봉" checked>
                        <span class="radio-text">미개봉</span>
                    </label>
                    <label class="radio-label">
                        <input type="radio" name="state" value="사용감 있음">
                        <span class="radio-text">사용감 있음</span>
                    </label>
                </div>
            </div>
        </div>

        <div class="divider"></div>

        <!-- 가격 -->
        <div class="form-section">
            <div class="form-label">
                <span class="label-text">가격</span>
                <span class="badge-required">필수</span>
            </div>
            <div class="form-content">
                <div class="price-wrap">
                    <input type="text" id="priceId" oninput="inputNumberFormat(this);"
                           placeholder="숫자만 입력해주세요" name="price" class="form-input price-input">
                    <span class="price-unit">원</span>
                </div>
                <span id="spanPrice" class="error-msg"></span>
            </div>
        </div>

        <div class="divider"></div>

        <!-- 설명 -->
        <div class="form-section">
            <div class="form-label">
                <span class="label-text">상품 설명</span>
                <span class="badge-required">필수</span>
            </div>
            <div class="form-content">
                <textarea id="explanId" name="explanation" class="form-textarea explan"
                    placeholder="구입 연도, 브랜드, 사용감, 하자 유무 등 구매자에게 필요한 정보를 입력해주세요. (10자 이상)"></textarea>
                <div class="textarea-footer">
                    <span id="spanExplan" class="error-msg"></span>
                    <span class="countExpaln">0/2000</span>
                </div>
            </div>
        </div>

        <div class="divider"></div>

        <!-- 상품 태그 -->
        <div class="form-section">
            <div class="form-label">
                <span class="label-text">상품 태그</span>
                <span class="badge-optional">선택</span>
            </div>
            <div class="form-content" style="position:relative;">
                <input type="text" id="searchTag" placeholder="태그를 입력하고 Enter" class="form-input" autocomplete="on">
                <div class="autocomplete"></div>
                <div id="relativeTagDiv"></div>
                <div class="tag-guide">
                    <p>• 태그는 최대 5개까지 선택 가능합니다.</p>
                    <p>• 선택된 태그의 x버튼을 클릭하면 삭제됩니다.</p>
                    <p>• 상품과 무관한 태그 입력 시 노출이 중단될 수 있습니다.</p>
                </div>
            </div>
        </div>

        <!-- 등록 버튼 -->
        <div class="regist-footer">
            <button type="button" class="btn-cancel" onclick="history.back()">취소</button>
            <button type="button" class="btn-submit" onclick="productRegist()">등록하기</button>
        </div>

    </div>
</div>

<script src="<%=request.getContextPath()%>/js/product/productregist.js"></script>

<%@ include file="../common/footer.jsp"%>
