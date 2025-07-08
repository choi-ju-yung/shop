<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>CoolSMS 쿨에스엠에스 api 사용</h1>
	전화번호<input type = "text" id="mTel">
	  <input type = "button" onclick="authnum()" class = "authbtn" value = "인증번호받기">
</body>
<script>
function authnum() {
	   var inputed = document.getElementById("mTel").value;
	   $.ajax({
	      data: {
	         mTel : inputed
	      },
	      url : "sendMessage",
	      success: function() {
	         $(".authbtn").prop("disabled",true);
	         $(".authbtn").css("display", "none");
	         $(".successMessage").css("display", "block");
	      }      
	   });
	}
</script>
</html>