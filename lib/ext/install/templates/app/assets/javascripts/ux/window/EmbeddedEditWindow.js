/**
 * @author Mark H Winkler
 * @class App.ux.window.EmbeddedEditWindow
 * @extends App.ux.window.EditWindow
 * <p>Extends ux.window.EditWindow to lood save and create records locally to store</p>
*/
Ext.define('App.ux.window.EmbeddedEditWindow', {
	extend: 'App.ux.window.EditWindow',
	
	// Make sure this is off since it's not implemented
	enableFormPaging: false,
	
	/**
  * Custom Config Params
	* Using model to load and update form
  */
	record: '',
		
	/**
  * New Record (recordID < 1) loads a new model
	* Existing Records loaded via form.load
  */
	loadRecord: function() {
		var me = this,
			formPanel = me.getComponent(me.formItemId);
			
		if (me.recordId < 0) {
			me.record = Ext.ModelManager.create({}, me.model);
		}
			
		formPanel.getForm().loadRecord(me.record);
		// fire event and pass model
		me.fireEvent('afterloadrecord', me, me.record);		
	},
	
	/**
  * Close window called from Cancel button
  */
	closeWindow: function() {
		this.close();
	},
	
	addRecord: function() {
		var me = this,
			grid = Ext.getCmp(me.gridId);
			
		grid.getStore().add(me.record);
	},
	
	/**
  * Loads form values into existing or new store model
  */
	saveRecord: function() {
		var me = this,
			form = me.getComponent(me.formItemId).getForm();
		
		if (form.isValid()) {
			// update or add record to local store
   		form.updateRecord(me.record);
			me.record.commit();
			if (me.recordId < 0) {
				me.addRecord();
			}
			me.closeWindow();
    }
	},
	
	/**
  * Call save and load new record
 	*/
	saveAddAnother: function() {
		var me = this;
		// save current and load blank record
		me.saveRecord();
		me.loadRecord();
	}
});