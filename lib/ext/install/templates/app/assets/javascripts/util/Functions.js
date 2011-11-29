Ext.define('App.util.Functions', {

	// application wide functions
	
	// fetches and returns field specific tooltips
	getHelpText: function(field) {
		var helpStore = Ext.data.StoreManager.lookup('definitionStore');
  	if (field && helpStore) {
    	var tooltip = '';
    	var index = helpStore.find('field', field);
    	if (index > -1) {
      	tooltip = helpStore.getAt(index).get('definition');
    	}
    	return tooltip;
		}
	},
	
	// sets the help icon and rollover text based id of the grid
	imageHelpTag: function(text, tooltipName){
		var me = this;
		
		var tooltip = me.getHelpText(tooltipName);
		if(tooltip != ''){
			return text+' <img id="'+tooltipName+'" class="aidu-grid-icon" src="/images/app/help.png">';
		}else{
			return text;
		}
	},
	
	defPopup: function(){
		
		var helpStore = Ext.data.StoreManager.lookup('definitionStore');
		if( helpStore ){
			var id = this.id.replace("defpopup_", "")
			var index = helpStore.find('id', id);

			var rec = helpStore.getAt(index).get('definition');
			var title = helpStore.getAt(index).get('name');

			var inst = new Ext.Panel({
				html : rec,
				unstyled : true,
				style : 'background-color: white',
				cls : 'instructions'
			});

			var win = new Ext.Window({
				modal: true,
				width: 400,
				resizable: false,
				constrainHeader: true,
				title: title,
				closable: true,
				items: inst
			});

			win.show();
		}
	}
	
});