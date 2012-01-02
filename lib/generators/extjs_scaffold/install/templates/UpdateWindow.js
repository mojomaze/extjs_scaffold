/**
 * @author Mark H Winkler
 * @class App.ux.window.UpdateWindow
 * @extends Ext.Window
 * <p>Ext.Window modal window used for updating all list detail.</p>
*/
Ext.define('<%= app_name %>.ux.window.UpdateWindow', {
	extend: 'Ext.Window',
	
	/**
 	* Config defaults
 	*/
	width: 600,
	modal: true,
	constrainHeader: true,
	resizable: false,
	closable: false,
	title: 'Update All Selected Records',
	
	// parent grid and child form ids
	gridId: '',
	formItemId: '',
	// array of selected record ids
	selectedRecords: [],
	
	initComponent: function() {
		var me = this;
		me.buttons = this.buildButtons();
		me.callParent(arguments);
	},
	
	/**
  * set up bottom window buttons
 	*/
	buildButtons: function() {
		var me = this;
		items = [];
		items.push({
        text: 'Cancel',
				scope: me,
        handler: me.closeWindow
    });
		
		items.push({
			text: 'Update All',
			scope: me,
      handler: me.updateAll
		});
	  
		return items;
	},
	
	/**
     * Close window called from Cancel button
     */
	closeWindow: function() {
		var me = this;
		me.close();
	},
	
	/**
   * Calls the associated grid uses gridId config
 	*/
	updateAll: function() {
		var me = this;
		var grid = Ext.getCmp(me.gridId);
		var formPanel = me.getComponent(me.formItemId);
		var form = formPanel.getForm();
		
		if (form.isValid()) {
			// get form data
			var fields = form.getFields().items;
			var updateObj = {};
			for(var i=0; i < fields.length; i++) {
				var field = fields[i];
				if (!field.isDisabled()) {
					if (field.getXType() == 'parentcombo') {
						// handle reference id and display fields
						// name = id - after []
						var pos = field.getName().indexOf(']');
						var idField = field.getName().substring(pos+1);
						var idValue = field.getValue();
						// id = display field
						if (idValue) {
							var displayField = field.getId();
							var displayValue = field.getStore().getById(idValue).get(field.displayField);
						
							updateObj[idField] = idValue;
							updateObj[displayField] = displayValue;
						}
					} else {
						updateObj[field.getId()] = field.getValue();
					}
				}
			}
			
			// update the selected records using updateObj fields
			var records = [];
			var record;
			for(i=0; i < me.selectedRecords.length; i++) {
				record = me.selectedRecords[i];
				for (var field in updateObj) {
					record.set(field, updateObj[field])
				}
			}
				
			// call the parent grids updateAll function
			grid.updateAllRecords(me.selectedRecords);
			me.closeWindow();
    }
	}
});