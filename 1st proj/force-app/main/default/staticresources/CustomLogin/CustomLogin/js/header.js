$(function(){

	// Menu hover
	var hoverConfig = {
		sensitivity: 5, 
		interval: 50, 
		timeout: 100,
		over: function(){
			
			if(!$(this).closest('li').hasClass('grey-out')){
				$(this).closest('li').addClass('active');
			}
			$(this).find('.sub-container').show();
		}, 
		 
		out: function(){
			$(this).closest('li').removeClass('active');
			$(this).find('.sub-container').stop().hide('fast');
		} 
	};

	$('#main-menu ul li, #tab-submenu ul li').hoverIntent(hoverConfig);

});