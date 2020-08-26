$(function(){

	// Hide all subs
	$('.jstree-closed ul').hide();


	// Tree expand
	$('.jstree-icon').toggle(
		function(){
			var parent = $(this).parent();
			if(parent.hasClass('jstree-closed')) {
				// Open
				parent.removeClass('jstree-closed').addClass('jstree-open');
				parent.find('ul').show();
			}
			else {
				// Close
				parent.removeClass('jstree-open').addClass('jstree-closed');	
				parent.find('ul').hide();
			}
		}, 
		function(){
			var parent = $(this).parent();
			if(parent.hasClass('jstree-closed')) {
				// Open
				parent.removeClass('jstree-closed').addClass('jstree-open');
				parent.find('ul').show();
			}
			else {
				// Close
				parent.removeClass('jstree-open').addClass('jstree-closed');	
				parent.find('ul').hide();
			}
		}
	);


	// Auto sizing
	var hoverConfig = {
		sensitivity: 5, 
		interval: 100, 
		over: function(){
			$(this).removeClass("box-1");
			$(this).addClass("box-fix-ie6");
		}, 
		out: function(){
			$(this).addClass("box-1");
			$(this).removeClass("box-fix-ie6");
		},
		timeout: 200
	};

	$('#productTree-container').hoverIntent(hoverConfig);

});