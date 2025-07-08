<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>로그인 성공</title>
</head>

<%
		request.getAttribute("user");
%>
<body>
    <h2>로그인 성공!</h2>
    <p>카카오 ID: ${user.id}</p>
    <p>닉네임: ${user.nickname}</p>
    <form action="/logout" method="get">
    	<button type="submit">로그아웃</button>
	</form>
    
    <p>${user}</p>
    <p>${sessionUser}</p>
</body>

<script>
</script>
</html>