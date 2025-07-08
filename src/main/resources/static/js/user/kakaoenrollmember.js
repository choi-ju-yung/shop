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

const checkObj = {  // 해당 회원가입 정보입력할 때, 정상적으로 처리됬는지 구분하는 객체
	"memberEmail": false,  
	"memberPw": false,
	"memberPwConfirm": false,
	"memberId": false,
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




function fn_registEnrollMember(){ 
	if(checkObj.memberEmail && checkObj.memberPw && checkObj.memberPwConfirm){
			return true;	
	}
	return false;
}
