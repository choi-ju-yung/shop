function checkSelectAll() {
	const checkboxes = document.querySelectorAll('input[name="agree"]');
	const checked = document.querySelectorAll('input[name="agree"]:checked');
	const selectAll = document.querySelector('input[name="selectall"]');
	selectAll.checked = checkboxes.length === checked.length;
}

function selectAll(selectAll) {
	document.getElementsByName('agree').forEach((cb) => { cb.checked = selectAll.checked; });
}

const fn_viewDetail1 = () => window.open("/popup/popup1", "팝업창1", 'width=600, height=600 left=650 top=250');
const fn_viewDetail2 = () => window.open("/popup/popup2", "팝업창2", 'width=600, height=600 left=650 top=250');
const fn_viewDetail3 = () => window.open("/popup/popup3", "팝업창3", 'width=600, height=600 left=650 top=250');
const fn_viewDetail4 = () => window.open("/popup/popup4", "팝업창4", 'width=600, height=600 left=650 top=250');

const regNickname = /^[가-힣a-zA-Z0-9]{2,12}$/;
const nicknameId = document.getElementById("nicknameId");
const nicknameMessage = $("#nicknameMessage");
const nicknameDupBtn = document.getElementById("nicknameDupBtn");
let nicknameChecked = false;

nicknameId.addEventListener("keyup", function() {
	nicknameChecked = false;
	const value = nicknameId.value;
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
		nicknameChecked = false;
		return;
	}
	$.ajax({
		url: "/regist/duplicateNickname",
		data: { nickname: value },
		success: function(result) {
			if (result === "1") {
				nicknameMessage.text("이미 사용 중인 닉네임입니다.").css("color", "red");
				nicknameChecked = false;
			} else {
				nicknameMessage.text("사용 가능한 닉네임입니다.").css("color", "green");
				nicknameChecked = true;
			}
		},
		error: function() {
			nicknameMessage.text("중복 확인 중 오류가 발생했습니다.").css("color", "red");
		}
	});
});

function fn_registEnrollMember() {
	const value = nicknameId.value.trim();
	if (!value) {
		nicknameMessage.text("닉네임을 입력해주세요.").css("color", "red");
		nicknameId.focus();
		return false;
	}
	if (!regNickname.test(value)) {
		nicknameMessage.text("2~12자의 한글/영문/숫자만 사용 가능합니다.").css("color", "red");
		nicknameId.focus();
		return false;
	}
	if (!nicknameChecked) {
		nicknameMessage.text("닉네임 중복 확인을 해주세요.").css("color", "red");
		nicknameId.focus();
		return false;
	}
	return true;
}
