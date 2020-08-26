var current_opacity = 0.0;
var HANDLE = 'handle';
var OVERLAY_CONT = 'overlayCont';
var OVERLAY_REF = 'overlayReference';
var OVERLAY_REF_END = 'overlayReferenceEnd';

var link10;
var link25;
var link50;
var link100;


function fireEvent(obj,evt){

	var fireOnThis = obj;
	if(document.createEvent){
		var evObj = document.createEvent('MouseEvents');
		evObj.initEvent( evt, true, false );
		fireOnThis.dispatchEvent(evObj);
	}
	else if(document.createEventObject){
		fireOnThis.fireEvent('on'+evt);
	}
}	
			
function showRows(obj,obj2){

	yy = (document.all)?document.body.scrollTop:window.pageYOffset; 
	
	document.getElementById(obj2).value = document.getElementById(obj).value
	if(document.getElementById(obj).value == "10"){
		fireEvent(document.getElementById(link10),'click');
	}
	else if(document.getElementById(obj).value == "25"){
		fireEvent(document.getElementById(link25),'click');
	}
	else if(document.getElementById(obj).value == "50"){
		fireEvent(document.getElementById(link50),'click');
	}
	else if(document.getElementById(obj).value == "100"){
		fireEvent(document.getElementById(link100),'click');
	}
	if(navigator.userAgent.toLowerCase().indexOf('safari') != -1){
		window.scrollBy(0,yy);
	}
}

function jump(e, btnUp) {
	
	var unicode=e.keyCode? e.keyCode : e.charCode;
	if(unicode == 13){
		document.getElementById(btnUp).click();
	}
}

function setFocus(obj){
	
	if(obj){
		document.getElementById(obj).focus();
	}
}

function mySubmit(e){
	
	var unicode=e.keyCode? e.keyCode : e.charCode;
	if(unicode != 13){
		return true;
	}
	else{
		return false;
	}
}