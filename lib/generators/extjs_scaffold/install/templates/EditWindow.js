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
	reloadOnCancel: false,
	submitDirtyOnly: true,
	/**
	* holding last save result
	* passed to update if cancel after save and add another
	*/
	lastSaveResult: '',
	
	initComponent: function() {
		var me = this;
		me.buttons = this.buildButtons();
		me.dockedItems = this.buildDockedItems();
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
		
		if( me.recordId == -3 ){
			items.push({
				text: 'Save and Add Another',
				scope: me,
	      handler: me.saveAddAnother
			});
		}
	  
		return items;
	},

	/**
  * set up top toobar with paging
	* this.enableFormPaging = true
  */
	
	buildDockedItems: function() {
		var me = this,
				items = [];
				
		if ( this.enableFormPaging && me.recordId != -3 ) {
			items.push({
				xtype: 'formpagingtoolbar',
				itemId: 'toptoolbar',
				dock: 'top',
				store: Ext.getCmp(me.gridId).getStore() 
			});
		}
		return items
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
			url: me.baseUrl+'/'+me.recordId+'/edit',
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
		if (me.reloadOnCancel) {
			var grid = Ext.getCmp(me.gridId);
			grid.updateRecord(me.recordId, null, me.lastSaveResult);
		}
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
		//var entity = grid.entitySingular.toLowerCase();
		var entity = 'data'; // changing root to match form load instead of EditWindow.entity
		
		// if submitDirtyOnly - don't submit form if no changes were made
		if ( me.submitDirtyOnly ) {
			if (!form.isDirty()) {
				me.closeWindow();
				return;
			}
		}
		
		if (form.isValid()) {
			form.submit({
 				waitMsg: 'Saving...',
 				success: function(form, action) {
					// added response flag for sectionCompleted in
					var updatedRecord = Ext.ModelManager.create(action.result[entity], me.model);
       		grid.updateRecord(me.recordId, updatedRecord, action.result);
					me.closeWindow();
 				}
     	});
    }
	},

	/**
  * 1) Saves current record (form.isDirty || submitDirtyOnly = false)
 	* 3) Loads new record
 	*/	
	moveRecord: function(newRecordId) {
		var me = this;
		var grid = Ext.getCmp(me.gridId);
		var formPanel = me.getComponent(me.formItemId);
		var form = formPanel.getForm();
		//var entity = grid.entitySingular.toLowerCase();
		var entity = 'data'; // changing root to match form load instead of EditWindow.entity
		
		// if submitDirtyOnly - don't submit form if no changes were made
		if ( me.submitDirtyOnly ) {
			if (!form.isDirty()) {
				me.recordId = newRecordId;
				me.moveLoadRecord('');
				// set the save url and method for new record
				form.url = me.recordId > 0 ? me.baseUrl+'/'+me.recordId : me.baseUrl;
				form.method = me.recordId > 0 ? 'PUT' : 'POST';
				return true;
			}
		}
		
		if (form.isValid()) {
			form.submit({
 				waitMsg: 'Saving...',
 				success: function(form, action) {
					// send the update record and response to the grid 
					// to update the record and handle section completed visuals
					var updatedRecord = Ext.ModelManager.create(action.result[entity], me.model);
					// don't update grid for new records until save and close
					if( newRecordId != -3 ) {
       			grid.updateRecord(me.recordId, updatedRecord, action.result);
					}
					me.lastSaveResult = action.result;
					me.recordId = newRecordId;
					me.moveLoadRecord('Last Item Saved');
					// set the save url and method for new record
					form.url = me.recordId > 0 ? me.baseUrl+'/'+me.recordId : me.baseUrl;
					form.method = me.recordId > 0 ? 'PUT' : 'POST';
 				}
     	});
    }
	},
	
	/**
  * Load record after moveRecord
	* Not using loadRecord for now b/c we have to call paging toolbar
  */
	moveLoadRecord: function(msg) {
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
			url: me.baseUrl+'/'+me.recordId+'/edit',
			method: 'GET',
			success: function(form, action) {
				me.getDockedComponent('toptoolbar').updateAfterMoveLoad(msg);
			},
			failure: function(form, action) {
				Ext.Msg.alert("Load failed", action.result.errorMessage);
			}
		});
		
	},
	
	/**
  * Call moveRecord with recordId = -3
 	*/
	saveAddAnother: function() {
		var me = this;
		// trigger grid reload on cancel to add new recs
		me.reloadOnCancel = true;
		// save current and load blank record
		me.moveRecord(-3);
	}
});