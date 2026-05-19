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

function fn_registEnrollMember() {
	return true;
}
