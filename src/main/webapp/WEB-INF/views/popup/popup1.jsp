<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>이용약관</title>
<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.0/dist/jquery.min.js"></script>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/popup/popup1.css" />
</head>
<body>
<div class="popWrap">
  <h2 class="popTitle">이용약관 동의</h2>

  <div class="termsBlock">
    <h4>이용약관</h4>
    <textarea readonly>제 1장 총칙

제 1 조 (목적)
본 약관은 니꺼내꺼 중고거래 플랫폼(이하 "서비스")이 제공하는 모든 서비스의 이용조건 및 절차, 회원과 서비스의 권리, 의무, 책임사항을 규정함을 목적으로 합니다.

제 2 조 (약관의 효력과 변경)
1. 이용자가 본 약관 내용에 동의하는 경우, 서비스 이용에 본 약관이 우선 적용됩니다.
2. 약관 개정 시 적용일자 및 개정사유를 명시하여 7일 이전부터 공지합니다.

제 3 조 (서비스 이용)
1. 서비스는 회원가입 후 이용 가능합니다.
2. 불법, 음란, 저속한 콘텐츠 게시는 금지됩니다.
3. 타인의 개인정보를 무단으로 수집·이용하는 행위는 금지됩니다.

제 4 조 (계정 관리)
1. 회원은 아이디와 비밀번호를 직접 관리할 책임이 있습니다.
2. 타인에게 계정 정보를 공유해서는 안 됩니다.

제 5 조 (서비스 중단)
천재지변, 시스템 장애 등 불가항력적 사유로 서비스가 중단될 수 있습니다.</textarea>
    <label class="agreeRow">
      <input type="checkbox" id="check_1"> 위의 이용약관에 동의합니다.
    </label>
  </div>

  <div class="termsBlock">
    <h4>개인정보 처리방침</h4>
    <textarea readonly>제 1 조 (수집하는 개인정보)
서비스는 회원가입 시 이름, 아이디, 이메일, 비밀번호를 수집합니다.

제 2 조 (개인정보의 이용 목적)
1. 서비스 제공 및 계정 관리
2. 고객 지원 및 분쟁 처리
3. 법령에 따른 의무 이행

제 3 조 (개인정보의 보관)
1. 회원 탈퇴 시 개인정보는 즉시 파기됩니다.
2. 단, 관계 법령에 의해 보존이 필요한 경우 해당 기간 동안 보관합니다.
3. 탈퇴 회원 기본정보는 개인정보보호법에 따라 5년간 별도 보관 후 파기됩니다.

제 4 조 (개인정보의 제3자 제공)
이용자의 사전 동의 없이 개인정보를 제3자에게 제공하지 않습니다.
단, 법령에 의한 요구가 있는 경우 예외로 합니다.</textarea>
    <label class="agreeRow">
      <input type="checkbox" id="check_2"> 위의 개인정보 처리방침에 동의합니다.
    </label>
  </div>

  <div class="termsBlock">
    <h4>개인정보 수집·이용 동의</h4>
    <textarea readonly>수집 항목: 이름, 아이디, 이메일, 비밀번호(암호화 저장)
수집 목적: 회원 서비스 제공, 본인 확인, 고객 지원
보유 기간: 회원 탈퇴 시까지 (법령 의무 보관 기간 별도)

위 내용에 동의하지 않으실 경우 서비스 이용이 제한될 수 있습니다.</textarea>
    <label class="agreeRow">
      <input type="checkbox" id="check_3"> 위의 개인정보 수집·이용에 동의합니다.
    </label>
  </div>

  <div class="popFooter">
    <button class="confirmBtn" id="nextBtn">동의하고 계속하기</button>
  </div>
</div>
ㅈ
<script>
$(function() {
  $('#nextBtn').click(function() {
    if (!$('#check_1').is(':checked') || !$('#check_2').is(':checked') || !$('#check_3').is(':checked')) {
      alert('모든 필수 약관에 동의해주세요.');
      return;
    }
    opener.document.getElementById('agree1').checked = true;
    window.close();
  });
});
</script>
</body>
</html>
