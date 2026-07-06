// input
/* 약관 동의 모두선택 기능 */
function checkSelectAll() {
	// 전체 체크박스
	const checkboxes // 전체 체크박스의 개수를 세기위해 만듬
		= document.querySelectorAll('input[name="agree"]');

	// 선택된 체크박스
	const checked
		= document.querySelectorAll('input[name="agree"]:checked');
	// select all 체크박스
	const selectAll
		= document.querySelector('input[name="selectall"]');

	if (checkboxes.length === checked.length) {  //  전체 체크개수와 현재 선택된 체크개수가 같으면 ->전체체크 상자에 체크해주고
		selectAll.checked = true;                   // 하나라도 박스에 체크가 빠지면, 전체체크 상자에 체크 표시 x
	} else {
		selectAll.checked = false;
	}
}


/* 팝업창 열게하는 기능 */
function selectAll(selectAll) {  // 이함수 호출시 1,2,3,4 체크부분들 다 체크표시로 설정
	const checkboxes
		= document.getElementsByName('agree');

	checkboxes.forEach((checkbox) => {
		checkbox.checked = selectAll.checked
	})
}

const fn_viewDetail1 = () => {
	window.open("/popup/popup1", "팝업창1", 'width=600, height=600 left=650 top=250'); // left, top -> 원하는 위치에 팝업창이 뜨도록 설정
}

const fn_viewDetail2 = () => {
	window.open("/popup/popup2", "팝업창2", 'width=600, height=600 left=650 top=250'); // left, top -> 원하는 위치에 팝업창이 뜨도록 설정
}

const fn_viewDetail3 = () => {
	window.open("/popup/popup3", "팝업창3", 'width=600, height=600 left=650 top=250'); // left, top -> 원하는 위치에 팝업창이 뜨도록 설정
}

const fn_viewDetail4 = () => {
	window.open("/popup/popup4", "팝업창4", 'width=600, height=600 left=650 top=250'); // left, top -> 원하는 위치에 팝업창이 뜨도록 설정
}



/**/

const checkObj = {
	"memberEmail": false,
	"memberId": false,
	"memberPw": false,
	"memberPwConfirm": false,
	"memberNickname": false,
	"sendEmail": false,
	"authNumber" : false
};


const memberEmail = document.getElementById("email");
/*const emailMessage = document.getElementById("emailMessageId");*/
const emailMessage = $("#emailMessageId");

memberEmail.addEventListener("keyup", function() {
	//입력이 되지 않은경우

	if (memberEmail.value.length == 0) {
		emailMessage.text("");
		checkObj.memberEmail = false;             // 기록할객체에 유효X 기록X  
		return;
	}

	//입력이 된 경우 (이메일 정규표현식)
	const regExp = /^[\w\-\_]{4,}@[\w\-\_]+(\.\w+){1,3}$/;


	if (regExp.test(memberEmail.value)) {   // 정규표현식 유효한경유
		// 이메일 중복검사 (ajax) 진행****************

		$.ajax({
			url: "/emailDupCheck",  // 필수속성 url ,
			method: 'POST',
			/*contentType: "application/x-www-form-urlencoded",*/
			// 현재주소 : /community/member/signUp
			// 상대경로 : /community/member/emailDupCheck
			data: { "memberEmail": memberEmail.value },
			// data속성 : 비동기통신시 서버로 전달할값을 작성(JS객체 형식)
			//  --> 비동기통신시 input에 입력된 값을
			// "memberEmail" 이라는 key값(파라미터) 으로 전달
			success: function(result) {
				// 비동기통신(.ajax)가 오류없이 요청/응답 성공한경우
				// 매개변수 result : Servlet에서 출력된 result값이 담겨있음
				if (result == 1) {    // 중복 O
					emailMessage.text("이미 사용중인 이메일입니다.").css("color", "red");

					checkObj.memberEmail = false;
				} else {     // 중복 X
					emailMessage.text("사용 가능한 이메일입니다.").css("color", "green");
					checkObj.memberEmail = true;          // 사용가능함. true 세팅
				}
			},
			error: function() {
				// 비동기통신(.ajax)중 오류가 발생한 경우
				console.log("에러발생");
			}

		});
	} else {            // 정규표현식 유효하지 않은경우
		emailMessage.text("이메일 형식이 유효하지 않습니다!!").css("color", "red");
		checkObj.memberEmail = false;           // 기록할객체에 유효X 기록X  
	}
});


// 아이디 중복검사 
const regId = /^[a-z0-9]{6,12}$/
const userId_ = document.getElementById("userId_");


userId_.addEventListener("keyup", function() {

	if (regId.test(userId_.value)) {

		$.ajax({
			url: "/regist/duplicateId",
			data: { "loginId": userId_.value },
			success: function(data) {
				if (data === '0') {
					$("#idDupMessageId").text("사용 가능한 아이디입니다.").css("color", "green");
					checkObj.memberId = true;
				} else {
					$("#idDupMessageId").text("이미 사용중인 아이디입니다.").css("color", "red");
					checkObj.memberId = false;
				}
			},

			error: function(data) {
				console.log(r);
				console.log(m);
			}
		});
	} else {
		$("#idDupMessageId").text("영소문자,숫자로만 6~12글자의 아이디를 입력하세요").css("color", "red");
		checkObj.memberId = false;
	}
})


const cNumber = document.getElementById("cNumber");
const cBtn = document.getElementById("cBtn");





// 비밀번호 중복검사 및 일치 규칙
const memberPw = document.getElementById("password");
const memberPwConfirm = document.getElementById("memberPwConfirm");
const pwMessage = $("#pwMessage");
/*const regExp2 = /^[\w!@#_-]{6,30}$/;*/
// 영대소문자, 숫자, 특수기호 최소 하나씩 8글자 이상
const regExp2 = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*~()_+])[a-zA-Z\d!@#$%^&*~()_+]{8,16}$/

memberPwConfirm.addEventListener("keyup", function() {
	console.log("dd");
	if (memberPw.value.length == 0 || memberPwConfirm.value.length == 0) {
		pwMessage.text("");
	}

	if (regExp2.test(memberPw.value) || regExp2.test(memberPwConfirm.value)) {

		if (memberPw.value == memberPwConfirm.value) {
			pwMessage.text("비밀번호가 일치합니다").css("color", "green");

			checkObj.memberPw = true;
			checkObj.memberPwConfirm = true;

		} else {
			pwMessage.text("비밀번호가 일치하지않습니다").css("color", "red");
			checkObj.memberPw = false;
			checkObj.memberPwConfirm = false;
		}

	}
	else {
		pwMessage.text("영대소문자, 숫자, 특수기호 포함 8글자 이상으로 작성").css("color", "red");
		checkObj.memberPw = false;
		checkObj.memberPwConfirm = false;
	}
});


memberPw.addEventListener("keyup", function() {
	console.log("dd");
	if (memberPw.value.length == 0 || memberPwConfirm.value.length == 0) {
		pwMessage.text("");
	}

	if (regExp2.test(memberPw.value) || regExp2.test(memberPwConfirm.value)) {

		if (memberPw.value == memberPwConfirm.value) {
			pwMessage.text("비밀번호가 일치합니다").css("color", "green");

			checkObj.memberPw = true;
			checkObj.memberPwConfirm = true;

		} else {
			pwMessage.text("영대소문자, 숫자, 특수기호 포함 8글자 이상으로 작성").css("color", "red");
			checkObj.memberPw = false;
			checkObj.memberPwConfirm = false;
		}

	}
	else {
		pwMessage.text("영대소문자, 숫자, 특수기호 포함 8글자 이상으로 작성").css("color", "red");
		checkObj.memberPw = false;
		checkObj.memberPwConfirm = false;
	}
});


// 닉네임 검증
const regNickname = /^[가-힣a-zA-Z0-9]{2,12}$/;
const nicknameId = document.getElementById("nicknameId");
const nicknameMessage = $("#nicknameMessage");
const nicknameDupBtn = document.getElementById("nicknameDupBtn");

nicknameId.addEventListener("keyup", function() {
	const value = nicknameId.value;
	checkObj.memberNickname = false;

	if (value.length === 0) {
		nicknameMessage.text("");
		return;
	}
	if (regNickname.test(value)) {
		nicknameMessage.text("중복확인 버튼을 눌러주세요.").css("color", "#888");
	} else {
		nicknameMessage.text("2~12자의 한글/영문/숫자만 사용 가능합니다.").css("color", "red");
	}
});

nicknameDupBtn.addEventListener("click", function() {
	const value = nicknameId.value.trim();
	if (!regNickname.test(value)) {
		nicknameMessage.text("2~12자의 한글/영문/숫자만 사용 가능합니다.").css("color", "red");
		checkObj.memberNickname = false;
		return;
	}
	$.ajax({
		url: "/regist/duplicateNickname",
		data: { nickname: value },
		success: function(result) {
			if (result === "1") {
				nicknameMessage.text("이미 사용 중인 닉네임입니다.").css("color", "red");
				checkObj.memberNickname = false;
			} else {
				nicknameMessage.text("사용 가능한 닉네임입니다.").css("color", "green");
				checkObj.memberNickname = true;
			}
		},
		error: function() {
			nicknameMessage.text("중복 확인 중 오류가 발생했습니다.").css("color", "red");
		}
	});
});



// 인증번호 보내기
let checkInterval = null; // 전역 변수로 타이머 ID를 저장할 변수 선언

const sendBtn = document.getElementById("authEmail");
const timerMessage = document.getElementById("timerMemssageId");
const timerMessageClass = $(".timerMessageClass");

sendBtn.addEventListener("click", function() {
	timerMessageClass.css("color", "black");

	if (checkObj.memberEmail) {  // 유효한 이메일이 작성되어 있을경우에만 메일보내기

		// 탈퇴 30일 제한 먼저 확인
		$.ajax({
			url: "/regist/checkWithdraw",
			method: "GET",
			data: { email: memberEmail.value },
			async: false, // 결과 확인 후 다음 로직 실행
			success: function(res) {
				if (res.restricted) {
					emailMessage.text(res.message).css("color", "red");
					checkObj.memberEmail = false;
					return;
				}
			},
			error: function() {}
		});

		if (!checkObj.memberEmail) return; // 탈퇴 제한 걸린 경우 중단

		checkObj.sendEmail = false;
		if (checkInterval) clearInterval(checkInterval); // 기존 타이머가 있으면 중지

		$.ajax({
			url: "/regist/sendEmail",
			method: "post",
			data: {
				"inputEmail": memberEmail.value,
				"requestIp": userIp.value
			},
			success: function(result) {
				checkObj.sendEmail = true;

			},
			error: function() {
				checkObj.sendEmail = false;
			}
		})

		timerMessageClass.text("5:00");// 초기값 5분

		min = 4;
		sec = 59;

		checkInterval = setInterval(function() {
			if (sec < 10) sec = "0" + sec;
			timerMessageClass.text(min + ":" + sec);

			if (Number(sec) === 0) {
				min--;
				sec = 59;
			} else {
				sec--;
			}
			if (min === -1) {
				timerMessageClass.text("인증번호가 만료되었습니다.").css("color", "red");
				clearInterval(checkInterval);  // setInterval 함수 반복을 지움.
				checkInterval = null;
				checkObj.sendEmail = false;
			}
		}, 1000);   // 1초 지연 후 수행
		alert("인증번호가 발송되었습니다. 이메일을 확인해주세요,,");
	}
});


const authButton = document.getElementById("cBtn");
const authNumber = document.getElementById("cNumber");
authButton.addEventListener("click", function() {
	if (checkObj.sendEmail = true) {
		$.ajax({
			url: "/regist/compareAuthNumber",
			method: "post",
			data: {
				"inputEmail": memberEmail.value,
				"authCode": authNumber.value
			},
			success: function(result) {
				
				if(result === true){
					alert("인증 성공");
					authButton.disabled = true;
					authNumber.disabled = true;
					sendBtn.disabled = true;
					memberEmail.readOnly = true;
					checkObj.authNumber = true;
					clearInterval(checkInterval);
					timerMessageClass.text("인증완료").css("color","green");
					emailMessage.text("사용 가능한 이메일입니다.").css("color", "green");
				}else{
					alert("인증번호가 다르거나 만료되었습니다.");
					checkObj.authNumber = false;
				}
								

			},
			error: function() {
				checkObj.authNumber = false;
			}
		})
	}

})


function fn_registEnrollMember() {
	if (!checkObj.memberEmail || !checkObj.authNumber) {
		emailMessage.text("이메일 인증을 완료해주세요.").css("color", "red");
		document.getElementById("email").focus();
		return false;
	}
	if (!checkObj.memberId) {
		$("#idDupMessageId").text("아이디 중복 확인이 필요합니다.").css("color", "red");
		document.getElementById("userId_").focus();
		return false;
	}
	if (!checkObj.memberPw || !checkObj.memberPwConfirm) {
		pwMessage.text("비밀번호를 확인해주세요.").css("color", "red");
		document.getElementById("password").focus();
		return false;
	}
	if (!checkObj.memberNickname) {
		nicknameMessage.text("닉네임 중복 확인이 필요합니다.").css("color", "red");
		document.getElementById("nicknameId").focus();
		return false;
	}
	return true;
}
