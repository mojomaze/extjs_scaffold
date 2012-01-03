/**
 * @author Mark H Winkler
 * @class App.ux.window.EditWindow
 * @extends Ext.Window
 * <p>Ext.Window modal window used for editing list detail.</p>
*/
Ext.define('<%= app_name %>.ux.window.EditWindow', {
	extend: 'Ext.Window',
	
	/**
 	* Config defaults
 	*/
	width: 600,
	modal: true,
	constrainHeader: true,
	resizable: false,
	closable: false,
	
	/**
  * Custom Config Params
  */
	recordId: -3,
	gridId: '',
	formItemId: '',
	model: '',
	baseUrl: '',
	submitDirtyOnly: true,
	/**
	* boolean trigger for grid load on cancel
	* used in save and add another
	*/
	submitDirtyOnly: true,
	
	initComponent: function() {
		var me = this;
		me.buttons = this.buildButtons();
		me.callParent(arguments);
		me.addEvents(
			/**
       * @event afterloadrecord
       * Fires after a blank record is loaded into the underlying form
       * @param {Ext.window.Window} this
       * @param {Ext.data.Model} record loaded
       */
      'afterloadrecord'
		);
		me.on('afterrender', this.loadRecord, this);
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
			text: 'Save and Close',
			scope: me,
      handler: me.saveRecord
		});
	  
		return items;
	},
	
	/**
  * New Record (recordID < 1) loads a new model
	* Existing Records loaded via form.load
  */
	loadRecord: function() {
		var me = this;
		var  formPanel = me.getComponent(me.formItemId);
		if (me.recordId < 1) {
			var newModel  = Ext.ModelManager.create({}, me.model);
			formPanel.getForm().loadRecord(newModel);
			// fire event and pass model
			me.fireEvent('afterloadrecord', me, newModel);
			return;
		}	
		
		formPanel.getForm().load({
			waitMsg: 'Loading...',
			// rails formatting for edit record
			url: me.baseUrl+'/'+me.recordId+'/edit.json',
			method: 'GET',
			failure: function(form, action) {
				Ext.Msg.alert("Load failed", action.result.errorMessage);
			}
		});
		
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
	 * Note that ajax failure is now handled automatically using json errors object
     */
	saveRecord: function() {
		var me = this;
		var grid = Ext.getCmp(me.gridId);
		var formPanel = me.getComponent(me.formItemId);
		var form = formPanel.getForm();
		var entity = 'data';

		if ( me.submitDirtyOnly ) { //don't submit form if no changes were made
			if (!form.isDirty()) {
				me.closeWindow();
				return;
			}
		}
		
		if (form.isValid()) {
			form.submit({
 				waitMsg: 'Saving...',
 				success: function(form, action) {
					var updatedRecord = Ext.ModelManager.create(action.result[entity], me.model);
       		grid.updateRecord(me.recordId, updatedRecord, action.result);
					me.closeWindow();
 				}
     	});
    }
	}
});