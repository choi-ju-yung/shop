<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>니꺼내꺼 Admin</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/adminMainView.css">
</head>
<body>

<!-- ══════════════ SIDEBAR ══════════════ -->
<aside class="sidebar">

  <div class="sidebar-brand">
    <div class="brand-logo">🛍️</div>
    <div class="brand-text">
      <div class="brand-name">니꺼내꺼</div>
      <div class="brand-sub">Admin Dashboard</div>
    </div>
  </div>

  <nav class="sidebar-nav">

    <div class="nav-section-label">메인</div>
    <a href="<%=request.getContextPath()%>/admin/adminMode" class="nav-link-item active">
      <i class="bi bi-grid-fill"></i> 대시보드
    </a>
    <a href="<%=request.getContextPath()%>/index.jsp" class="nav-link-item">
      <i class="bi bi-box-arrow-up-right"></i> 사용자 페이지
    </a>

    <div class="nav-divider"></div>
    <div class="nav-section-label">관리</div>

    <a href="<%=request.getContextPath()%>/memberList.do" class="nav-link-item">
      <i class="bi bi-people-fill"></i> 회원 관리
    </a>

    <a href="<%=request.getContextPath()%>/boardListAdmin.do" class="nav-link-item">
      <i class="bi bi-megaphone-fill"></i> 공지사항 관리
    </a>

    <a href="<%=request.getContextPath()%>/reportListAdmin.do" class="nav-link-item">
      <i class="bi bi-flag-fill"></i> 미처리 신고
    </a>

    <a href="<%=request.getContextPath()%>/completeReportList.do" class="nav-link-item">
      <i class="bi bi-check-circle-fill"></i> 처리된 신고
    </a>

    <a href="<%=request.getContextPath()%>/productAdmin.do" class="nav-link-item">
      <i class="bi bi-box-seam-fill"></i> 상품 관리
    </a>

    <div class="nav-divider"></div>
    <div class="nav-section-label">시스템</div>

    <a href="#" class="nav-link-item" onclick="openBannerManager(); return false;">
      <i class="bi bi-image-fill"></i> 배너 관리
    </a>

    <a href="#" class="nav-link-item" onclick="scrollToEs(); return false;">
      <i class="bi bi-search"></i> 검색 엔진 관리
    </a>

  </nav>

  <div class="sidebar-footer">
    <a href="<%=request.getContextPath()%>/index.jsp">
      <i class="bi bi-arrow-left-circle"></i> 메인으로 돌아가기
    </a>
  </div>

</aside>
<!-- ══════════════════════════════════════ -->


<!-- ══════════════ MAIN ══════════════════ -->
<div class="main-content">

  <!-- Top Header -->
  <header class="top-header">
    <div class="page-title">
      <i class="bi bi-grid-fill"></i> 대시보드
    </div>
    <div class="header-right">
      <a href="<%=request.getContextPath()%>/index.jsp" class="header-site-link">
        <i class="bi bi-box-arrow-up-right"></i> 사용자 페이지
      </a>
      <div class="admin-avatar">
        <i class="bi bi-person-fill"></i>
      </div>
    </div>
  </header>

  <!-- Content Body -->
  <div class="content-body">

    <!-- Quick Nav Pills -->
    <div class="quick-nav">
      <a href="<%=request.getContextPath()%>/memberList.do" class="quick-pill">
        <i class="bi bi-people-fill"></i> 회원 조회
      </a>
      <a href="<%=request.getContextPath()%>/boardListAdmin.do" class="quick-pill">
        <i class="bi bi-megaphone-fill"></i> 공지사항
      </a>
      <a href="<%=request.getContextPath()%>/reportListAdmin.do" class="quick-pill">
        <i class="bi bi-flag-fill"></i> 미처리 신고
      </a>
      <a href="<%=request.getContextPath()%>/completeReportList.do" class="quick-pill">
        <i class="bi bi-check-circle-fill"></i> 처리 완료
      </a>
      <a href="<%=request.getContextPath()%>/productAdmin.do" class="quick-pill">
        <i class="bi bi-box-seam-fill"></i> 상품 관리
      </a>
      <a href="#" class="quick-pill" onclick="openBannerManager(); return false;">
        <i class="bi bi-image-fill"></i> 배너 관리
      </a>
    </div>

    <!-- Action Cards -->
    <div class="section-label mb-3">
      <i class="bi bi-lightning-fill"></i> 바로가기
    </div>
    <div class="row g-3 mb-4">

      <div class="col-xl-4 col-md-6">
        <a href="<%=request.getContextPath()%>/memberList.do" class="action-card">
          <div class="action-icon icon-blue"><i class="bi bi-people-fill"></i></div>
          <div>
            <div class="action-card-title">회원 관리</div>
            <div class="action-card-desc">전체 회원 조회 및 관리</div>
          </div>
        </a>
      </div>

      <div class="col-xl-4 col-md-6">
        <a href="<%=request.getContextPath()%>/boardListAdmin.do" class="action-card">
          <div class="action-icon icon-green"><i class="bi bi-megaphone-fill"></i></div>
          <div>
            <div class="action-card-title">공지사항 관리</div>
            <div class="action-card-desc">공지사항 등록 및 수정</div>
          </div>
        </a>
      </div>

      <div class="col-xl-4 col-md-6">
        <a href="<%=request.getContextPath()%>/reportListAdmin.do" class="action-card">
          <div class="action-icon icon-red"><i class="bi bi-flag-fill"></i></div>
          <div>
            <div class="action-card-title">미처리 신고</div>
            <div class="action-card-desc">처리되지 않은 신고글 확인</div>
          </div>
        </a>
      </div>

      <div class="col-xl-4 col-md-6">
        <a href="<%=request.getContextPath()%>/completeReportList.do" class="action-card">
          <div class="action-icon icon-slate"><i class="bi bi-check-circle-fill"></i></div>
          <div>
            <div class="action-card-title">처리된 신고</div>
            <div class="action-card-desc">처리 완료된 신고 목록</div>
          </div>
        </a>
      </div>

      <div class="col-xl-4 col-md-6">
        <a href="<%=request.getContextPath()%>/productAdmin.do" class="action-card">
          <div class="action-icon icon-orange"><i class="bi bi-box-seam-fill"></i></div>
          <div>
            <div class="action-card-title">상품 관리</div>
            <div class="action-card-desc">상품 게시물 조회 및 관리</div>
          </div>
        </a>
      </div>

      <div class="col-xl-4 col-md-6">
        <a href="#" class="action-card" onclick="openBannerManager(); return false;">
          <div class="action-icon icon-purple"><i class="bi bi-image-fill"></i></div>
          <div>
            <div class="action-card-title">배너 관리</div>
            <div class="action-card-desc">메인 광고 배너 등록 및 관리</div>
          </div>
        </a>
      </div>

    </div>

    <!-- ES Sync Card -->
    <div class="section-label mb-3" id="es-section">
      <i class="bi bi-database-fill-gear"></i> 검색 엔진 관리
    </div>
    <div class="es-card mb-5">
      <div class="es-card-icon"><i class="bi bi-lightning-charge-fill"></i></div>
      <div class="es-card-body">
        <h6>Elasticsearch 전체 재동기화</h6>
        <p>ES 인덱스가 날아가거나 데이터 불일치 발생 시,<br>DB 기준으로 상품과 태그를 전체 재동기화합니다.</p>
      </div>
      <div class="es-card-actions">
        <button class="btn-sync" id="syncBtn" onclick="syncEs()">
          <i class="bi bi-arrow-repeat"></i> 재동기화 실행
        </button>
        <div class="sync-result" id="syncResult"></div>
      </div>
    </div>

  </div><!-- /content-body -->
</div>
<!-- ══════════════════════════════════════ -->


<!-- ══════════════ BANNER MODAL ══════════ -->
<div class="modal fade" id="bannerModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title"><i class="bi bi-image-fill me-2 text-purple" style="color:#9333ea;"></i>광고 배너 관리</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">

        <!-- 배너 등록 폼 -->
        <div class="card mb-4">
          <div class="card-header fw-semibold">
            <i class="bi bi-plus-circle me-1"></i> 새 배너 등록
          </div>
          <div class="card-body">
            <div class="row g-3">
              <div class="col-12">
                <label class="form-label small fw-semibold">배너 이미지 <span class="text-danger">*</span></label>
                <input type="file" id="bannerImageFile" class="form-control form-control-sm" accept="image/*">
              </div>
              <div class="col-12">
                <label class="form-label small fw-semibold">클릭 시 이동 URL</label>
                <input type="text" id="bannerLinkUrl" class="form-control form-control-sm" placeholder="예) /product/category">
              </div>
              <div class="col-4">
                <label class="form-label small fw-semibold">노출 순서</label>
                <input type="number" id="bannerSortOrder" class="form-control form-control-sm" value="1" min="1">
              </div>
              <div class="col-4">
                <label class="form-label small fw-semibold">시작일</label>
                <input type="date" id="bannerStartDt" class="form-control form-control-sm">
              </div>
              <div class="col-4">
                <label class="form-label small fw-semibold">종료일</label>
                <input type="date" id="bannerEndDt" class="form-control form-control-sm">
              </div>
              <div class="col-12">
                <button class="btn btn-primary btn-sm w-100" onclick="submitBanner()">
                  <i class="bi bi-check-lg me-1"></i> 배너 등록
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- 배너 목록 -->
        <div class="card">
          <div class="card-header fw-semibold">
            <i class="bi bi-list-ul me-1"></i> 등록된 배너 목록
          </div>
          <div class="card-body p-0">
            <table class="table table-hover table-sm mb-0" id="bannerTable">
              <thead class="table-light">
                <tr>
                  <th class="ps-3" style="width:50px;">순서</th>
                  <th style="width:80px;">미리보기</th>
                  <th>링크</th>
                  <th>기간</th>
                  <th style="width:70px;">상태</th>
                  <th style="width:120px;">관리</th>
                </tr>
              </thead>
              <tbody id="bannerTableBody"></tbody>
            </table>
          </div>
        </div>

      </div>
    </div>
  </div>
</div>
<!-- ══════════════════════════════════════ -->


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>
var ctx = '<%=request.getContextPath()%>';

/* ── Banner ─────────────────────────────── */
function openBannerManager() {
  loadBannerList();
  new bootstrap.Modal(document.getElementById('bannerModal')).show();
}

function loadBannerList() {
  $.ajax({
    url: ctx + '/admin/banner/list',
    type: 'GET',
    dataType: 'json',
    success: function(list) {
      var html = '';
      if (!list || list.length === 0) {
        html = '<tr><td colspan="6" class="text-center text-muted py-4 small">등록된 배너가 없습니다.</td></tr>';
      } else {
        list.forEach(function(b) {
          var badge = b.isActive === 'Y'
            ? '<span class="badge bg-success">노출중</span>'
            : '<span class="badge bg-secondary">숨김</span>';
          var toggleLabel = b.isActive === 'Y' ? '숨기기' : '노출';
          var toggleVal   = b.isActive === 'Y' ? 'N' : 'Y';
          var period = (b.startDt || '-') + ' ~ ' + (b.endDt || '-');
          html += '<tr>'
            + '<td class="ps-3">' + b.sortOrder + '</td>'
            + '<td><img src="' + ctx + b.imageUrl + '" style="height:42px;border-radius:6px;object-fit:cover;"></td>'
            + '<td><small class="text-muted">' + (b.linkUrl || '-') + '</small></td>'
            + '<td><small class="text-muted">' + period + '</small></td>'
            + '<td>' + badge + '</td>'
            + '<td>'
              + '<button class="btn btn-xs btn-outline-secondary me-1" style="font-size:11px;padding:2px 8px;" onclick="toggleBanner(' + b.bannerId + ',\'' + toggleVal + '\')">' + toggleLabel + '</button>'
              + '<button class="btn btn-xs btn-outline-danger" style="font-size:11px;padding:2px 8px;" onclick="deleteBanner(' + b.bannerId + ')">삭제</button>'
            + '</td>'
            + '</tr>';
        });
      }
      $('#bannerTableBody').html(html);
    }
  });
}

function submitBanner() {
  var file = document.getElementById('bannerImageFile').files[0];
  if (!file) { alert('이미지를 선택해주세요.'); return; }
  var formData = new FormData();
  formData.append('imageFile', file);
  formData.append('linkUrl',   $('#bannerLinkUrl').val());
  formData.append('sortOrder', $('#bannerSortOrder').val());
  formData.append('startDt',   $('#bannerStartDt').val());
  formData.append('endDt',     $('#bannerEndDt').val());
  $.ajax({
    url: ctx + '/admin/banner/insert',
    type: 'POST',
    data: formData,
    processData: false,
    contentType: false,
    success: function() {
      alert('배너가 등록되었습니다.');
      $('#bannerImageFile').val('');
      loadBannerList();
    },
    error: function(xhr) { alert('등록 실패: ' + xhr.responseText); }
  });
}

function toggleBanner(bannerId, isActive) {
  $.ajax({
    url: ctx + '/admin/banner/toggle/' + bannerId,
    type: 'POST',
    data: { isActive: isActive },
    success: function() { loadBannerList(); }
  });
}

function deleteBanner(bannerId) {
  if (!confirm('배너를 삭제하시겠습니까?')) return;
  $.ajax({
    url: ctx + '/admin/banner/delete/' + bannerId,
    type: 'DELETE',
    success: function() { loadBannerList(); }
  });
}

/* ── ES Sync ─────────────────────────────── */
function syncEs() {
  var $btn    = $('#syncBtn');
  var $result = $('#syncResult');
  $btn.prop('disabled', true).html('<i class="bi bi-arrow-repeat"></i> 동기화 중...');
  $result.hide();
  $.ajax({
    url: ctx + '/admin/es/sync',
    type: 'POST',
    dataType: 'json',
    success: function(data) {
      $result.html('<i class="bi bi-check-circle me-1"></i>완료 — 상품 <b>' + data.products + '</b>건 · 태그 <b>' + data.tags + '</b>건').show();
    },
    error: function() {
      $result.html('<i class="bi bi-x-circle me-1"></i>동기화 실패').show();
    },
    complete: function() {
      $btn.prop('disabled', false).html('<i class="bi bi-arrow-repeat"></i> 재동기화 실행');
    }
  });
}

function scrollToEs() {
  document.getElementById('es-section').scrollIntoView({ behavior: 'smooth', block: 'start' });
}
</script>

</body>
</html>
