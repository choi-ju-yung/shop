
const context = "http://localhost:9090/semi-hifive";


const checkProductRegist = {  // 상품등록할 때, 각 부분마다 정상적으로 처리됬는지 구분하는 객체 (다 true일경우에만 상품등록됨)
	"productImg": false,  
	"productTitle": false,
	"productPlace": false,
	"productPrice": false,
	"productExplan": false,
};



// 사진 불러오기 작업 

let prouductImgCnt = 0;
const dataTransfer = new DataTransfer();


function getImageFiles(e) {
	const files = e.currentTarget.files;
	const imagePreview = document.querySelector('.image-preview');

	const newFiles = [...files];
	let currentCount = dataTransfer.items.length;

	for (let file of newFiles) {

		// 파일 타입 검사
		if (!file.type.match("image/.*")) {
			alert('이미지 파일만 업로드가 가능합니다.');
			continue;
		}

		// 중복 검사: 이미 dataTransfer에 같은 파일 있는지 확인
		let isDuplicate = false;
		for (let i = 0; i < dataTransfer.items.length; i++) {
			const existingFile = dataTransfer.items[i].getAsFile();
			if (
				existingFile.name === file.name &&
				existingFile.lastModified === file.lastModified &&
				existingFile.size === file.size
			) {
				isDuplicate = true;
				break;
			}
		}

		if (isDuplicate) {
			alert(`이미 업로드한 이미지입니다: ${file.name}`);
			continue;
		}

		// 총 이미지 수 검사 (현재 있는 이미지 + 새로 추가할 이미지)
		if (currentCount >= 10) {
			alert('이미지는 최대 10개까지 업로드 가능합니다.');
			break; // 루프 종료 (계속하면 추가될 수도 있음)
		}

		// FileReader로 미리보기 추가
		const reader = new FileReader();
		reader.onload = (e) => {
			const preview = createElement(e, file);
			imagePreview.appendChild(preview);
		};

		reader.readAsDataURL(file);
		dataTransfer.items.add(file); // 실제 파일 저장
		currentCount++; // 새로 추가된 이미지 개수 증가
		prouductImgCnt++;
		$(".imgCount").text("(" + prouductImgCnt + "/10" + ")");
	}
}


// 태그 만들어주는 함수
function createElement(e, file) {
	const li = document.createElement('li');    // li 태그 만들기
	const img = document.createElement('img');  // img 태그 만들기
	img.setAttribute('src', e.target.result); // 만든 img 태그에 경로 속성 값 넣어줌
	img.setAttribute('data-file', file.name); // 만들 ing 태그에 파일 이름 속성 값 넣어줌
	img.setAttribute('data-modified', file.lastModified);
	img.setAttribute('data-size', file.size);
	checkProductRegist.productImg = true; 
	
	
	img.addEventListener("click", e => {  // 해당 이미지 클릭시
		console.log(prouductImgCnt);
		prouductImgCnt--; // 이미지 삭제시 개수 감소
		$(e.target).parent().remove(); // li안의 img까지 삭제
		$(".imgCount").text("(" + prouductImgCnt + "/10" + ")");
		
		 for(var i=0; i<dataTransfer.files.length; i++){
             if(dataTransfer.files[i].name==e.target.dataset.file){
                    dataTransfer.items.remove(i)
                    break;
             }
          }
		
		
		if(dataTransfer.files.length == 0){  
			checkProductRegist.productImg = false; 
		}
		
	});

	li.appendChild(img); // 이미지가 있는 li 태그 완성하여 li 리턴

	return li;
}




const realUpload = document.querySelector('.real-upload');
const upload = document.querySelector('.upload');

upload.addEventListener('click', () => realUpload.click()); // 이미지등록 클록시 input file타입 호출
realUpload.addEventListener('change', getImageFiles); // file타입에서 값 변경시키면 getImageFiles() 함수 호출




// ==== 가격 입력했을 때, 숫자만입력되고, 3자리수마다 ,로 구분해주는 작업
function comma(str) {
	str = String(str);
	return str.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, "$1,");
}

function uncomma(str) {
	str = String(str);
	return str.replace(/[^\d]+/g, "");
}

function inputNumberFormat(obj) {
	obj.value = comma(uncomma(obj.value));
}


const priceValue = document.getElementById("priceId")
const spanPrice = $("#spanPrice");
priceValue.addEventListener("keyup", function() {

	if (priceValue.value.length == 0) {
		spanPrice.text("");
		checkProductRegist.productPrice=false;
	}else{
		replacePrice = priceValue.value.replace(",","");
		if(replacePrice <= 0){
			spanPrice.text("0원보다 크게 입력하세요").css("color","red");
			checkProductRegist.productPrice=false;
		}else{
			spanPrice.text("○").css("color","green");
			checkProductRegist.productPrice=true;
		}
	}
});


//=====================================================

const spanTitle = $("#spanTitle");
// ==== 제목 글자수 세주는 작업=====
$(".inputTitle").keyup(e => { // 해당 텍스트부분을 입력할 때
	$(".countTitle").text($(e.target).val().length + "/20");
	const length = $(e.target).val().length;
	
	if (length>20) {
		alert("20글자 이하로 작성하세요");
		$(e.target).val($(e.target).val().substring(0, 20));
		checkProductRegist.productTitle=false;
	}
	
	if(length<=0){
		spanTitle.text("");
		checkProductRegist.productTitle=false;
	}else if(length<10){
		spanTitle.text("최소 10글자 이상 작성하세요").css("color","red");
		checkProductRegist.productTitle=false;
	}else{
		spanTitle.text("");
		checkProductRegist.productTitle=true;
	}
	
	$(".countTitle").text($(e.target).val().length + "/20");
})


// -------------------------------------------------------------------------------------------------------------------
// 카테고리 선택하는 작업

$(() => {
	$(".mainCate").trigger("change", $(".mainCate:selected").val());  // 페이지로딩되었을때, 자동으로 change 함수 실행
	//	대상값은 현재 그 select에 선택된 값
})

function chageSubCate(value) {
	console.log(value);
	$.ajax({
		url: "/user/findSubCate",
		data: { "categoryName": value },
		success: function(result) {

			const subCate = result.split(","); // 문자열로 넘어온 값들을 ,를 구분자로 배열을 만듬

			$(".middleCate option").remove();   // 메인카테고리 선택할때마다 옵션들 다 삭제
			for (let i = 0; i < subCate.length; i++) {
				var option = $("<option value=" + subCate[i] + ">" + subCate[i] + "</option>");
				$(".middleCate").append(option);
			}
		},
		error: function() {
			console.log("카테고리 선택 오류발생");
		}
	})
}

/*$(function() {
	var arr = ["서울", "경기도", "인천"];
	for(var i=0; i<arr.length; i++){
	var optionLabel = arr[i];
	var optionValue = 65+i;  
	optionValue = String.fromCharCode(optionValue); // 밸류값을 알파벳으로 바꿈
	
	
	var option = $("<option value=" + optionValue + ">" + optionLabel+"</option>");
	$(".mainCate").append(option);
	}
});*/


// -------------------------------------------------------------------------------------------------------------------

// 거래지역 선택 (api 코드)
function sample6_execDaumPostcode() {
	new daum.Postcode({
		oncomplete: function(data) {
			// 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

			// 각 주소의 노출 규칙에 따라 주소를 조합한다.
			// 내려오는 변수가 값이 없는 경우엔 공백('')값을 가지므로, 이를 참고하여 분기 한다.
			var addr = ''; // 주소 변수
			var extraAddr = ''; // 참고항목 변수

			//사용자가 선택한 주소 타입에 따라 해당 주소 값을 가져온다.
			if (data.userSelectedType === 'R') { // 사용자가 도로명 주소를 선택했을 경우
				addr = data.roadAddress;
			} else { // 사용자가 지번 주소를 선택했을 경우(J)
				addr = data.jibunAddress;
			}

			// 사용자가 선택한 주소가 도로명 타입일때 참고항목을 조합한다.
			if (data.userSelectedType === 'R') {
				// 법정동명이 있을 경우 추가한다. (법정리는 제외)
				// 법정동의 경우 마지막 문자가 "동/로/가"로 끝난다.
				if (data.bname !== '' && /[동|로|가]$/g.test(data.bname)) {
					extraAddr += data.bname;
				}
				// 건물명이 있고, 공동주택일 경우 추가한다.
				if (data.buildingName !== '' && data.apartment === 'Y') {
					extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
				}
				// 표시할 참고항목이 있을 경우, 괄호까지 추가한 최종 문자열을 만든다.
				if (extraAddr !== '') {
					extraAddr = ' (' + extraAddr + ')';
				}
				// 조합된 참고항목을 해당 필드에 넣는다.
				document.getElementById("sample6_extraAddress").value = extraAddr;

			} else {
				document.getElementById("sample6_extraAddress").value = '';
			}

			// 우편번호와 주소 정보를 해당 필드에 넣는다.
			document.getElementById('sample6_postcode').value = data.zonecode;
			document.getElementById("sample6_address").value = addr;
			// 커서를 상세주소 필드로 이동한다.
			document.getElementById("sample6_address").focus();
		}
	}).open();
}


const placeValue = document.getElementById("sample6_address");
const spanPlace = $("#spanPlace");
/*		spanPlace.text("지역을 반드시 선택해주세요").css("color","red");
		checkProductRegist.productPlace=false;
/*const placeLen = document.getElementById("sample6_address");*/
/*   $(function() {
		if(placeValue.value.length == 0){
			spanPlace.text("지역을 반드시 선택해주세요").css("color","red");
			checkProductRegist.productPlace=false;
		}else{
			spanPlace.text("○").css("color","green");
			checkProductRegist.productPlace=true;
		}
   });*/

placeValue.addEventListener("input", function() {
		spanPlace.text("○").css("color","green");
		checkProductRegist.productPlace=true;
});




// -------------------------------------------------------------------------------------------------------------------



const spanExplan = $("#spanExplan");
// ==== 설명 글자수 세주는 작업=====
$(".explan").keyup(e => { // 해당 텍스트부분을 입력할 때
	$(".countExpaln").text($(e.target).val().length + "/40");
	const length = $(e.target).val().length;

	if (length>2000) {
		alert("2000글자 이하로 작성하세요");
		$(e.target).val($(e.target).val().substring(0, 2000));
		checkProductRegist.productExplan=false;
	}else if(length>10){
		spanExplan.text("○").css("color","green");
		checkProductRegist.productExplan=true;
	}else if(length>0){
		spanExplan.text("최소 10글자 이상 작성하세요").css("color","red");
		checkProductRegist.productExplan=false;
	}else{
		spanExplan.text("").css("color","red");
		checkProductRegist.productExplan=false;
	}
	
	$(".countExpaln").text($(e.target).val().length + "/2000");
})


// -------------------------------------------------------------------------------------------------------------------

const dataList = [
  "#패션", "#패션의류", "#자켓", "#상의", "#스포츠", "#도서", "#전자기기", "#노트북", "#가구", "#생활", "#차량", "#악세서리",
  "#캠핑", "#등산", "#모니터", "#마우스", "#키보드", "#에어컨", "#헤드셋", "#레고", "#피규어", "#슬리퍼", "#책", "#소설", "#가방"
];

let registTagList = [];

const $searchTag = document.querySelector("#searchTag");
const $autoComplete = document.querySelector(".autocomplete");
const $relativeTagDiv = document.querySelector("#relativeTagDiv");

let nowIndex = 0;
let matchDataList = [];

$searchTag.addEventListener("keyup", (event) => {
  const value = $searchTag.value.trim();

  switch (event.keyCode) {
    case 38: // ↑
      nowIndex = Math.max(nowIndex - 1, 0);
      break;

    case 40: // ↓
      nowIndex = Math.min(nowIndex + 1, matchDataList.length - 1);
      break;

    case 13: // Enter
      if (matchDataList.length === 0) return;

      const selectedTag = matchDataList[nowIndex] || value;
      addTag(selectedTag);
      resetAutoComplete();
      return;

    case 27: // ESC
      resetAutoComplete();
      return;

    default:
      matchDataList = value
        ? dataList.filter((tag) => tag.toLowerCase().includes(value.toLowerCase()))
        : [];
      nowIndex = 0;
      break;
  }

  showList(matchDataList, value, nowIndex);
});

// 검색창 외부 클릭 시 자동완성 닫기
document.addEventListener("click", (event) => {
  const isClickInside = $searchTag.contains(event.target) || $autoComplete.contains(event.target);
  if (!isClickInside) {
    resetAutoComplete();
  }
});



$autoComplete.addEventListener("click", (e) => {
  let selected = e.target.textContent.trim();
  addTag(selected);
  resetAutoComplete();
});

function showList(data, keyword, highlightIndex) {
  const regex = new RegExp(`(${keyword})`, "gi");

  $autoComplete.innerHTML = data
    .map((tag, index) => {
      const highlighted = tag.replace(regex, "<label>$1</label>");
      return `<div class="${highlightIndex === index ? "active" : ""}">${highlighted}</div>`;
    })
    .join("");

  // ✅ 현재 highlight된 항목이 보이도록 스크롤
  const activeItem = $autoComplete.querySelector(".active");
  if (activeItem) {
    activeItem.scrollIntoView({ block: "nearest", behavior: "smooth" });
  }
}

function addTag(tag) {
  if (!tag || registTagList.includes(tag)) {
	alert("이미 존재하는 키워드입니다.");
	return;
  }
  if (registTagList.length >= 5) {
    alert("태그는 최대 5개까지만 추가 가능합니다.");
    return;
  }

  registTagList.push(tag);

  const $li = document.createElement("li");

  const $label = document.createElement("label");
  $label.textContent = tag;

  const $button = document.createElement("button");
  $button.type = "button";
  $button.style.border = "none";
  $button.style.backgroundColor = "transparent";

  const $img = document.createElement("img");
  $img.src = (typeof contextPath !== "undefined" ? contextPath : "") + "/css/images/productregist/xbtn.png";
  $img.width = 15;
  $img.height = 15;

  $img.addEventListener("click", (e) => {
    const tagText = e.target.closest("li").querySelector("label").textContent;
    registTagList = registTagList.filter((t) => t !== tagText);
    $li.remove();
  });

  $button.appendChild($img);

  const $hiddenInput = document.createElement("input");
  $hiddenInput.type = "hidden";
  $hiddenInput.name = "tag";
  $hiddenInput.value = tag;

  $li.appendChild($label);
  $li.appendChild($button);
  $li.appendChild($hiddenInput);

  $relativeTagDiv.appendChild($li);
}

function resetAutoComplete() {
  matchDataList.length = 0;
  nowIndex = 0;
  $searchTag.value = "";
  $autoComplete.innerHTML = "";
}



function productRegist() {  // 상품등록 버튼 클릭됬을 때,
	

	if(checkProductRegist.productTitle && checkProductRegist.productPrice && checkProductRegist.productExplan
		&& checkProductRegist.productImg){
	}else{
			console.log("다 입력해라")
			return;
	}


	
	const form = new FormData();  // form 객체에 입력한 값들을 먼저 다 추가함
	form.append("title", $(".inputTitle").val());
	form.append("subCate", $(".middleCate").val());
	form.append("place", $("#sample6_address").val());
	form.append("state", $("input[name=state]:checked").val());
	form.append("price", $("#priceId").val())
	form.append("explanation", $("#explanId").val())
	form.append("mainImageIndex",0);
	let tag="";
	$("input[name=tag]").each((i,element)=>{ // jquery로 해당 선택자로 값을 가져옴 .each(i,elemnet) -> 해당 데이터들의 인덱스번호와, 해당 값을 가져옴  
		if(i!=0) tag+=",";
		tag+=element.value;	
	})
	form.append("tag",tag); 
	
	const files= dataTransfer.files;
	/*const files=$("input[type=file]")[0].files;*/ // 

	$.each(files,(index,file)=>{
		//form.append("upfile"+index,file);
		form.append("files",file);
		console.log(files[index]);
	});


	$.ajax({
		url: "/user/productRegistEnd", // 해당 서블릿으로 ajax로 요청
		data: form,   // 저정한 form 객체를 데이터로 보냄
		processData:false, // 멀티파트폼으로 보내기위해서 설정
		contentType:false, // 멀티파트폼으로 보내기위해서 설정
		type:"post",
		success: function(result) {
			if(result === "1") { // db는 결과값이 정수로 나옴 // 입력성공
					alert("등록 성공");
					location.replace("/user/main"); // 올바른 리다이렉트 방식
			}else{ 
					alert("등록 실패");
					location.replace("/user/productRegist");
			}
		},
		error: function() {
			alert("오류발생");
			location.replace("http://localhost:9090/semi-hifive/"+"productRegist.do");
		}
	})
}

/*================================================================================================*/

function productUpdate() {  // 상품수정 버튼 클릭됬을 때,
	
	if(checkProductRegist.productTitle && checkProductRegist.productPrice && checkProductRegist.productExplan
		&& checkProductRegist.productImg){
	}else{
			console.log("다 입력해라")
			return;
	}

	const form = new FormData();  // form 객체에 입력한 값들을 먼저 다 추가함
	form.append("productId",$(".inputProductId").val());
	form.append("title", $(".inputTitle").val());
	form.append("subCate", $(".middleCate").val());
	form.append("place", $("#sample6_address").val());
	form.append("state", $("input[name=state]:checked").val());
	form.append("price", $("#priceId").val())
	form.append("explan", $("#explanId").val())
	let tag="";
	$("input[name=data1]").each((i,element)=>{ // jquery로 해당 선택자로 값을 가져옴 .each(i,elemnet) -> 해당 데이터들의 인덱스번호와, 해당 값을 가져옴  
		if(i!=0) tag+=",";
		tag+=element.value;	
	})
	form.append("tag",tag); 
	form.append("mainImageIndex",0); 
	const files= dataTransfer.files;
	/*const files=$("input[type=file]")[0].files;*/ // 

	$.each(files,(index,file)=>{
		form.append("upfile"+index,file);
		console.log(files[index]);
	});


	$.ajax({
		url: "productUpdateEnd.do", // 해당 서블릿으로 ajax로 요청
		data: form,   // 저정한 form 객체를 데이터로 보냄
		processData:false, // 멀티파트폼으로 보내기위해서 설정
		contentType:false, // 멀티파트폼으로 보내기위해서 설정
		type:"post",
		success: function(result) {
			if(result>=1) { // db는 결과값이 정수로 나옴 // 입력성공
					alert("수정 성공");
					location.replace("http://localhost:9090/semi-hifive/");
			}else{ 
					alert("수정 실패");
					location.replace("http://localhost:9090/semi-hifive/"+"productUpdate.do");
			}
		},
		error: function() {
			alert("오류발생");
			location.replace("http://localhost:9090/semi-hifive/"+"productRegist.do");
		}
	})
}



