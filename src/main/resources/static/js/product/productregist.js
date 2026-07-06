

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
const imagePreview = document.querySelector('.image-preview');
let dragSrcIndex = -1;


function getImageFiles(e) {
	const files = e.currentTarget.files;
	const newFiles = [...files];
	let currentCount = dataTransfer.items.length;

	for (let file of newFiles) {

		// 파일 타입 검사
		if (!file.type.match("image/.*")) {
			alert('이미지 파일만 업로드가 가능합니다.');
			continue;
		}

		// 파일 크기 검사 (10MB)
		if (file.size > 10 * 1024 * 1024) {
			alert(`파일 크기가 너무 큽니다. 10MB 이하의 이미지만 업로드 가능합니다.\n(${file.name}: ${(file.size / 1024 / 1024).toFixed(1)}MB)`);
			continue;
		}

		// 중복 검사
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

		// 최대 10개 검사
		if (currentCount >= 10) {
			alert('이미지는 최대 10개까지 업로드 가능합니다.');
			break;
		}

		const reader = new FileReader();
		reader.onload = (ev) => {
			const preview = createElement(ev, file);
			imagePreview.appendChild(preview);
			updateRepresentativeBadge();
		};
		reader.readAsDataURL(file);
		dataTransfer.items.add(file);
		currentCount++;
		prouductImgCnt++;
		$(".imgCount").text("(" + prouductImgCnt + "/10)");
	}

	// 삭제 후 동일 파일 재선택이 가능하도록 input 초기화
	realUpload.value = "";
}


function deleteImage(li, fileName, fileModified, fileSize) {
	li.remove();
	prouductImgCnt--;
	$(".imgCount").text("(" + prouductImgCnt + "/10)");

	for (let i = 0; i < dataTransfer.files.length; i++) {
		const f = dataTransfer.files[i];
		if (f.name === fileName && f.lastModified == fileModified && f.size == fileSize) {
			dataTransfer.items.remove(i);
			break;
		}
	}

	if (dataTransfer.files.length === 0) {
		checkProductRegist.productImg = false;
	}

	updateRepresentativeBadge();
}


function reorderDataTransfer(fromIndex, toIndex) {
	const files = [...dataTransfer.files];
	const [moved] = files.splice(fromIndex, 1);
	files.splice(toIndex, 0, moved);
	while (dataTransfer.items.length > 0) {
		dataTransfer.items.remove(0);
	}
	files.forEach(f => dataTransfer.items.add(f));
}


function updateRepresentativeBadge() {
	[...imagePreview.querySelectorAll('li')].forEach((li, index) => {
		const badge = li.querySelector('.badge-representative');
		if (badge) badge.style.display = index === 0 ? 'block' : 'none';
	});
}


function createElement(e, file) {
	const li = document.createElement('li');
	li.setAttribute('draggable', 'true');

	// 미리보기 이미지
	const img = document.createElement('img');
	img.setAttribute('src', e.target.result);
	img.setAttribute('data-file', file.name);
	img.setAttribute('data-modified', file.lastModified);
	img.setAttribute('data-size', file.size);
	checkProductRegist.productImg = true;

	// X 삭제 버튼
	const deleteBtn = document.createElement('button');
	deleteBtn.type = 'button';
	deleteBtn.className = 'img-delete-btn';
	const xImg = document.createElement('img');
	xImg.src = '/images/productregist/xbtn.png';
	xImg.width = 2;
	xImg.height = 2;
	deleteBtn.appendChild(xImg);
	deleteBtn.addEventListener('click', (ev) => {
		ev.stopPropagation();
		deleteImage(li, file.name, file.lastModified, file.size);
	});

	// 대표이미지 배지
	const badge = document.createElement('span');
	badge.className = 'badge-representative';
	badge.textContent = '대표';
	badge.style.display = 'none';

	li.appendChild(img);
	li.appendChild(deleteBtn);
	li.appendChild(badge);

	// 드래그 이벤트
	li.addEventListener('dragstart', (ev) => {
		dragSrcIndex = [...imagePreview.children].indexOf(li);
		ev.dataTransfer.effectAllowed = 'move';
		setTimeout(() => li.classList.add('dragging'), 0);
	});

	li.addEventListener('dragover', (ev) => {
		ev.preventDefault();
		ev.dataTransfer.dropEffect = 'move';
	});

	li.addEventListener('drop', (ev) => {
		ev.preventDefault();
		ev.stopPropagation();
		const dropIndex = [...imagePreview.children].indexOf(li);
		if (dragSrcIndex !== -1 && dragSrcIndex !== dropIndex) {
			const draggedEl = imagePreview.children[dragSrcIndex];
			if (dragSrcIndex < dropIndex) {
				imagePreview.insertBefore(draggedEl, li.nextSibling);
			} else {
				imagePreview.insertBefore(draggedEl, li);
			}
			reorderDataTransfer(dragSrcIndex, dropIndex);
			updateRepresentativeBadge();
		}
	});

	li.addEventListener('dragend', () => {
		li.classList.remove('dragging');
		dragSrcIndex = -1;
	});

	// 이미지 클릭 시 확대 모달
	li.addEventListener('click', () => {
		openImageModal(img.getAttribute('src'));
	});

	return li;
}


const realUpload = document.querySelector('.real-upload');
const upload = document.querySelector('.upload');

upload.addEventListener('click', () => realUpload.click());

const uploadArea = document.querySelector('.image-upload-area');
uploadArea.addEventListener('click', (e) => {
	if (e.target !== upload) realUpload.click();
});

realUpload.addEventListener('change', getImageFiles);


// ===================== 이미지 확대 모달 =====================
(function() {
	const modal = document.createElement('div');
	modal.id = 'img-modal';
	modal.innerHTML = `
		<div class="img-modal-content">
			<img id="img-modal-img" src="">
			<button class="img-modal-close">&#x2715;</button>
		</div>
	`;
	document.body.appendChild(modal);

	modal.addEventListener('click', (e) => {
		if (e.target === modal) closeImageModal();
	});
	modal.querySelector('.img-modal-close').addEventListener('click', closeImageModal);
	document.addEventListener('keydown', (e) => {
		if (e.key === 'Escape') closeImageModal();
	});
})();

function openImageModal(src) {
	document.getElementById('img-modal-img').src = src;
	document.getElementById('img-modal').style.display = 'flex';
}

function closeImageModal() {
	document.getElementById('img-modal').style.display = 'none';
}


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
		url: "/member/sell/subcategory",
		data: { "categoryName": value },
		success: function(result) {

			const subCate = result.split(","); // 문자열로 넘어온 값들을 ,를 구분자로 배열을 만듬

			$(".middleCate option").remove();   // 메인카테고리 선택할때마다 옵션들 다 삭제
			for (let i = 0; i < subCate.length; i++) {
				var option = $("<option value=" + subCate[i] + ">" + subCate[i] + "</option>");
				$(".middleCate").append(option);
			}
		},
		error: function(xhr, status, err) {
			console.error("카테고리 오류:", xhr.status, err);  // 개발자용 로그
			$(".middleCate option").remove();
			$(".middleCate").append('<option value="">불러오기 실패</option>');
			$(".middleCate").prop("disabled", true);
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

// 거래지역 선택 - 도로명주소 API (행정안전부 juso.go.kr)
function sample6_execDaumPostcode() {
    var modal = document.getElementById('addressModal');
    modal.style.display = 'flex';
    document.getElementById('addrKeyword').focus();
}

function closeAddrModal() {
    document.getElementById('addressModal').style.display = 'none';
    document.getElementById('addrKeyword').value = '';
    document.getElementById('jusoResults').innerHTML = '';
}

function searchJuso() {
    var keyword = document.getElementById('addrKeyword').value.trim();
    if (!keyword) return;

    var list = document.getElementById('jusoResults');
    list.innerHTML = '<li style="padding:12px;color:#9ca3af;text-align:center;">검색 중...</li>';

    fetch('/api/address/search?keyword=' + encodeURIComponent(keyword))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            list.innerHTML = '';
            var results = data.results;
            if (!results || results.length === 0) {
                list.innerHTML = '<li style="padding:14px;color:#9ca3af;text-align:center;">검색 결과가 없습니다.</li>';
                return;
            }
            results.forEach(function(item) {
                var li = document.createElement('li');
                li.style.cssText = 'padding:12px 14px; border-bottom:1px solid #f3f4f6; cursor:pointer;';
                li.onmouseover = function() { this.style.background = '#f8fffe'; };
                li.onmouseout  = function() { this.style.background = ''; };
                li.innerHTML =
                    '<div style="font-size:14px;font-weight:600;color:#111827;">' + item.roadAddr + '</div>' +
                    '<div style="font-size:12px;color:#9ca3af;margin-top:2px;">지번: ' + item.jibunAddr + '</div>';
                li.onclick = function() {
                    document.getElementById('sample6_address').value = item.roadAddr;
                    document.getElementById('sample6_postcode').value = item.zipNo;
                    spanPlace.text("○").css("color", "green");
                    checkProductRegist.productPlace = true;
                    closeAddrModal();
                };
                list.appendChild(li);
            });
        })
        .catch(function() {
            list.innerHTML = '<li style="padding:14px;color:#ef4444;text-align:center;">검색 중 오류가 발생했습니다.</li>';
        });
}

// 모달 외부 클릭 시 닫기
document.getElementById('addressModal').addEventListener('click', function(e) {
    if (e.target === this) closeAddrModal();
});


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

let registTagList = [];

const $searchTag = document.querySelector("#searchTag");
const $autoComplete = document.querySelector(".autocomplete");
const $relativeTagDiv = document.querySelector("#relativeTagDiv");

let nowIndex = -1;
let matchDataList = [];
let searchDebounceTimer = null;
let lastSearchedValue = "";

// 네비게이션만 keyup으로 처리
$searchTag.addEventListener("keyup", (event) => {
  const value = $searchTag.value.trim();

  switch (event.keyCode) {
    case 38: // ↑
      nowIndex = Math.max(nowIndex - 1, -1);
      showList(matchDataList, value, nowIndex);
      break;

    case 40: // ↓
      nowIndex = Math.min(nowIndex + 1, matchDataList.length - 1);
      showList(matchDataList, value, nowIndex);
      break;

    case 13: // Enter
      if (matchDataList.length === 0 || nowIndex < 0) return;
      addTag(matchDataList[nowIndex]);
      resetAutoComplete();
      return;

    case 27: // ESC
      resetAutoComplete();
      return;
  }
});

// 검색 AJAX — 값이 바뀔 때만 실행 (한글 ↓키가 input 이벤트 발생시켜도 같은 값이면 무시)
$searchTag.addEventListener("input", () => {
  const value = $searchTag.value.trim();
  if (!value) {
    matchDataList = [];
    $autoComplete.innerHTML = "";
    lastSearchedValue = "";
    return;
  }
  if (value === lastSearchedValue) return;
  lastSearchedValue = value;
  clearTimeout(searchDebounceTimer);
  searchDebounceTimer = setTimeout(() => {
    $.ajax({
      url: "/product/tags",
      data: { keyword: value },
      success: function(result) {
        matchDataList = result;
        nowIndex = 0;
        showList(matchDataList, value, nowIndex);
      },
      error: function() {
        matchDataList = [];
        $autoComplete.innerHTML = "";
      }
    });
  }, 200);
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
  $img.src = (typeof contextPath !== "undefined" ? contextPath : "") + "/images/productregist/xbtn.png";
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
  nowIndex = -1;
  lastSearchedValue = "";
  $searchTag.value = "";
  $autoComplete.innerHTML = "";
}



function productRegist() {  // 상품등록 버튼 클릭됬을 때,
	

	if(!Object.values(checkProductRegist).every(Boolean)){  //객체의 모든 값을 배열로 변환시킨 후 하나라도 false면 false 반환
		alert("필수항목표시에 다 기입하세요");
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
		url: "/member/sell", // 해당 서블릿으로 ajax로 요청
		data: form,   // 저정한 form 객체를 데이터로 보냄
		processData:false, // 멀티파트폼으로 보내기위해서 설정
		contentType:false, // 멀티파트폼으로 보내기위해서 설정
		type:"post",
		success: function(result) {
			if(result === "1") { // db는 결과값이 정수로 나옴 // 입력성공
					alert("등록 성공");
					location.replace("/main");
			}else{
					alert("등록 실패");
					location.replace("/member/sell");
			}
		},
		error: function() {
			alert("오류발생");
			location.replace("/member/sell");
		}
	})
}

/*================================================================================================*/

function productUpdate() {  // 상품수정 버튼 클릭됬을 때,
	
	if(!Object.values(checkProductRegist).every(Boolean)){
		console.log("다 입력해라");
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
		url: "/member/sell/update", // 해당 서블릿으로 ajax로 요청
		data: form,   // 저정한 form 객체를 데이터로 보냄
		processData:false, // 멀티파트폼으로 보내기위해서 설정
		contentType:false, // 멀티파트폼으로 보내기위해서 설정
		type:"post",
		success: function(result) {
			if(result>=1) { // db는 결과값이 정수로 나옴 // 입력성공
					alert("수정 성공");
					location.replace("/main");
			}else{
					alert("수정 실패");
					location.replace("/member/sell");
			}
		},
		error: function() {
			alert("오류발생");
			location.replace("/member/sell");
		}
	})
}



