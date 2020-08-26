/*
 * Tracking file for the Engineers'corner
 * http://nxpsemiconductors.force.com
 */
_engineersCornerTrckng = {
	channel: 'engineers-corner',
	hier1: 'engineers-corner',
	param: 'dc',

	init: function() {
		// Check dependencies - Omniture
		if(typeof s_gi != 'function'){
			return;
		}
		// Omniture object
		var oOmniture = s;
		oOmniture.linkTrackVars = 'none';
		oOmniture.linkTrackEvents = 'none';
		var oOmnitureProps = {};
		var sEvents = "";
		// Set events
		oOmniture.linkTrackEvents = sEvents;
		oOmniture.events = sEvents;
		
		var query = window.location.hash;
		query = query.replace("#!/","&");
		
		var cat = this.getQueryVariable(query,this.param);
		
		oOmniture.pageName = window.location.pathname + cat;
		oOmniture.channel = this.channel;
		if (cat != '') { cat = ':' + cat; }
		oOmniture.hier1 = this.hier1 + cat;
		oOmniture.tl();
	},
	
	getQueryVariable : function (query,variable) {
		var vars = query.split("&"); 
		for (var i=0;i<vars.length;i++) { 
			var pair = vars[i].split("=");			
			if (pair[0].toLowerCase() == variable) { 
				return pair[1]; 
			} 
		} 
		return '';
	}	
}
 // Execute tracking
 _engineersCornerTrckng.init();