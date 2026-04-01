<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/adminHome.css" />
    
    <title>Document</title>
</head>
<body>  
    <aside class="sidebar">
      <div class="front">
        <h3 class="text-lime text-center mt-4 mb-4"><a href="<%=request.getContextPath()%>/adminMode.do">Home</a></h3>
        <h3 class="text-white text-center mt-4 mb-4"><a href="<%=request.getContextPath()%>/index.jsp">사용자페이지</a></h3>
      </div>
      <div class="menubal ">
        <div class="accordion" id="accordionPanelsStayOpenExample">
            <div class="accordion-item">
              <h2 class="accordion-header" id="panelsStayOpen-headingOne">
                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#panelsStayOpen-collapseOne" aria-expanded="true" aria-controls="panelsStayOpen-collapseOne">
                  회원관리
                </button>
              </h2>
              <div id="panelsStayOpen-collapseOne" class="accordion-collapse collapse" aria-labelledby="panelsStayOpen-headingOne">
                <div class="accordion-body">
                  <a href="<%=request.getContextPath()%>/memberList.do">회원조회</a>
                </div>
<!--                 <div class="accordion-body">
                    탈퇴한 회원조회
                  </div> -->
              </div>
            </div>
            <div class="accordion-item">
              <h2 class="accordion-header" id="panelsStayOpen-headingTwo">
                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#panelsStayOpen-collapseTwo" aria-expanded="false" aria-controls="panelsStayOpen-collapseTwo">
                  고객센터 관리
                </button>
              </h2>
              <div id="panelsStayOpen-collapseTwo" class="accordion-collapse collapse" aria-labelledby="panelsStayOpen-headingTwo">
                <div class="accordion-body">
                  <a href="<%=request.getContextPath()%>/boardListAdmin.do">공지사항 관리</a>
                </div>
                <div class="accordion-body">
                  <a href="<%=request.getContextPath()%>/reportListAdmin.do">처리되지 않은 신고글</a>
                </div>
                <div class="accordion-body">
                  <a href="<%=request.getContextPath()%>/completeReportList.do">처리된 신고글</a>
                </div>
              </div>
            </div>
            <div class="accordion-item">
              <h2 class="accordion-header" id="panelsStayOpen-headingThree">
                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#panelsStayOpen-collapseThree" aria-expanded="false" aria-controls="panelsStayOpen-collapseThree">
                  상품 관리
                </button>
              </h2>
              <div id="panelsStayOpen-collapseThree" class="accordion-collapse collapse" aria-labelledby="panelsStayOpen-headingThree">
                <div class="accordion-body">
                    <a href="<%=request.getContextPath()%>/productAdmin.do">상품 게시물 관리</a>
                </div>
              </div>
            </div>

            <div class="accordion-item">
              <h2 class="accordion-header" id="panelsStayOpen-headingBanner">
                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#panelsStayOpen-collapseBanner" aria-expanded="false" aria-controls="panelsStayOpen-collapseBanner">
                  배너 관리
                </button>
              </h2>
              <div id="panelsStayOpen-collapseBanner" class="accordion-collapse collapse" aria-labelledby="panelsStayOpen-headingBanner">
                <div class="accordion-body">
                  <a href="#" onclick="openBannerManager(); return false;">배너 등록/관리</a>
                </div>
              </div>
            </div>

          </div>
        </div>
    </nav>
    </aside>

    <!-- 배너 관리 모달 -->
    <div class="modal fade" id="bannerModal" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">광고 배너 관리</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">

            <!-- 배너 등록 폼 -->
            <div class="card mb-4">
              <div class="card-header fw-bold">새 배너 등록</div>
              <div class="card-body">
                <div class="row g-2">
                  <div class="col-12">
                    <label class="form-label">배너 이미지 <span class="text-danger">*</span></label>
                    <input type="file" id="bannerImageFile" class="form-control" accept="image/*">
                  </div>
                  <div class="col-12">
                    <label class="form-label">클릭 시 이동 URL</label>
                    <input type="text" id="bannerLinkUrl" class="form-control" placeholder="예) /user/category">
                  </div>
                  <div class="col-4">
                    <label class="form-label">노출 순서</label>
                    <input type="number" id="bannerSortOrder" class="form-control" value="1" min="1">
                  </div>
                  <div class="col-4">
                    <label class="form-label">시작일</label>
                    <input type="date" id="bannerStartDt" class="form-control">
                  </div>
                  <div class="col-4">
                    <label class="form-label">종료일</label>
                    <input type="date" id="bannerEndDt" class="form-control">
                  </div>
                  <div class="col-12 mt-2">
                    <button class="btn btn-success w-100" onclick="submitBanner()">배너 등록</button>
                  </div>
                </div>
              </div>
            </div>

            <!-- 배너 목록 -->
            <div class="card">
              <div class="card-header fw-bold">등록된 배너 목록</div>
              <div class="card-body p-0">
                <table class="table table-hover mb-0" id="bannerTable">
                  <thead class="table-light">
                    <tr>
                      <th>순서</th>
                      <th>미리보기</th>
                      <th>링크</th>
                      <th>기간</th>
                      <th>상태</th>
                      <th>관리</th>
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script>
    var ctx = '<%=request.getContextPath()%>';

    function openBannerManager() {
        loadBannerList();
        new bootstrap.Modal(document.getElementById('bannerModal')).show();
    }

    function loadBannerList() {
        $.ajax({
            url: ctx + '/admin/banner/list',
            type: 'GET',
            dataType: 'json',
            success: function (list) {
                var html = '';
                if (!list || list.length === 0) {
                    html = '<tr><td colspan="6" class="text-center text-muted py-3">등록된 배너가 없습니다.</td></tr>';
                } else {
                    list.forEach(function (b) {
                        var activeLabel = b.isActive === 'Y'
                            ? '<span class="badge bg-success">노출중</span>'
                            : '<span class="badge bg-secondary">숨김</span>';
                        var toggleLabel = b.isActive === 'Y' ? '숨기기' : '노출';
                        var toggleVal   = b.isActive === 'Y' ? 'N' : 'Y';
                        var period = (b.startDt || '-') + ' ~ ' + (b.endDt || '-');
                        html += '<tr>' +
                            '<td>' + b.sortOrder + '</td>' +
                            '<td><img src="' + ctx + b.imageUrl + '" style="height:50px;border-radius:6px;"></td>' +
                            '<td><small>' + (b.linkUrl || '-') + '</small></td>' +
                            '<td><small>' + period + '</small></td>' +
                            '<td>' + activeLabel + '</td>' +
                            '<td>' +
                              '<button class="btn btn-sm btn-outline-primary me-1" onclick="toggleBanner(' + b.bannerId + ',\'' + toggleVal + '\')">' + toggleLabel + '</button>' +
                              '<button class="btn btn-sm btn-outline-danger" onclick="deleteBanner(' + b.bannerId + ')">삭제</button>' +
                            '</td>' +
                            '</tr>';
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
        formData.append('imageFile',  file);
        formData.append('linkUrl',    $('#bannerLinkUrl').val());
        formData.append('sortOrder',  $('#bannerSortOrder').val());
        formData.append('startDt',    $('#bannerStartDt').val());
        formData.append('endDt',      $('#bannerEndDt').val());

        $.ajax({
            url: ctx + '/admin/banner/insert',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function () {
                alert('배너가 등록되었습니다.');
                $('#bannerImageFile').val('');
                loadBannerList();
            },
            error: function (xhr) { alert('등록 실패: ' + xhr.responseText); }
        });
    }

    function toggleBanner(bannerId, isActive) {
        $.ajax({
            url: ctx + '/admin/banner/toggle/' + bannerId,
            type: 'POST',
            data: { isActive: isActive },
            success: function () { loadBannerList(); }
        });
    }

    function deleteBanner(bannerId) {
        if (!confirm('배너를 삭제하시겠습니까?')) return;
        $.ajax({
            url: ctx + '/admin/banner/delete/' + bannerId,
            type: 'DELETE',
            success: function () { loadBannerList(); }
        });
    }
    </script>

</body>
</html>