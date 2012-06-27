/**
 * @author Mark H Winkler
 * @class App.ux.grid.Panel
 * @extends Ext.grid.Panel
 * <p>Extends grid.Panel to establish list grid config defaults.</p>
*/
Ext.define('<%= app_name %>.ux.grid.Panel', {
	extend: 'Ext.grid.Panel',

	/**
	* Config defaults
	*/
	multiSelect: true,

	enableColumnHide: false,
	enableColumnMove: false,
	enableColumnResize: false,

	height: 600,
	width: 800,

	preventHeader: true,

	style: {
		marginTop: '10px',
		marginBottom: '10px'
	},

	/**
	* Custom Config Params
	*/
	// used in dialogs and detail form titles
	//  entitySingular also used in editWindow.saveRecord() 
	//  for response root (action.result[entity])
	entitySingular: 'Record',
	entityPlural: 'Records',
	// edit window class used in openEditWindow()
	editWindow: 'App.ux.window.EditWindow',
	
	// update window class used in openUpdateWindow()
	updateWindow: 'App.ux.window.UpdateWindow',
	
	// enabling top bar buttons by default
	enableRemoteSearch: true,
	enableAddRecord: true,
	enableDeleteRecord: true,
	enableUpdateAll: true,
	enableStoreReload: true,

	// hides the bottom bar
	hideBottomToolbar: false,

	initComponent: function() {
		this.dockedItems = this.buildDockedItems();
		this.callParent(arguments);
		this.on('itemdblclick', this.onDblClick, this);
	},

	/**
	* Setup for top and bottom toolbars
	*/
	buildDockedItems: function() {
		var me = this,
			topitems = [],
			toolbars = [];

		if ( me.enableRemoteSearch ) {
			topitems.push({ xtype: 'searchfield', store: me.store });
			topitems.push( '-' );
		}

		if ( me.enableAddRecord ) {
			topitems.push({ 
				text: 'Add Record',
				tooltip: 'Add new '+this.entitySingular,
				iconCls: 'add',
				scope: me,
				handler: me.newRecord 
			});
			topitems.push( '-' );
		}
	
		if ( me.enableDeleteRecord ) {
			topitems.push({
				text: 'Delete All',
				tooltip: 'Delete selected records',
				iconCls: 'remove',
				scope: me,
				handler: me.deleteRecords
			});
			topitems.push( '-' );
		}
    		
		if ( me.enableUpdateAll ) {
			topitems.push({
				text: 'Update All',
				tooltip: 'Update all selected records',
				iconCls: 'updateall',
				scope: me,
				handler: me.updateAll
			});
			topitems.push( '-' );
		}
		
		toolbars.push({
			xtype: 'toolbar',
			itemId: 'toptoolbar',
		  dock: 'top',
			items: topitems
		});
		
		return toolbars;
	},
	
	/**
	* Grid double click handler
	*/
	onDblClick: function(view, record, item, index, event, options) {
		this.editRecord(record);
	},
		
	/**
	* Opens edit window with new record
	* called from top toolbar Add button
	*/
	newRecord: function() {
		this.openEditWindow(-3);
	},
	
	/**
	* Opens edit window with passed record
	* called from onDblClick handler
	*/
	editRecord: function(record) {
		if (record) { // edit the record
			var recordId = record.get('id');
			this.openEditWindow(recordId);
		}
	},
	
	/**
	* Uses the App.ux.data.Actionable mixin to delete one or more records
	* called from top toolbar Delete button
	*/
	deleteRecords: function() {
		var me = this;
		var records = me.getSelectionModel().getSelection();
		if (records.length > 0) {
			// confirm that records should be deleted
			var entity = records.length > 1 ? me.entityPlural : me.entitySingular;
			Ext.Msg.confirm('Warning','Do you really want to delete '+records.length+' '+entity+'. This cannot be undone!', function(btn){
				if(btn=='yes'){
					me.setLoading('Deleting..');
					// call the actionable mixin in the store
					me.getStore().doAction('destroy_all', records,
						{
							success: function(operation){
								me.setLoading(false);
								me.getStore().load();
							},
							failure: function(operation){
								me.setLoading(false);
								alert('Could not delete, changes rolled back');
							}
					});
				};
			});
		}
	},

	/**
	* Opens update window if records are selected
	* called from onDblClick handler
	*/
	updateAll: function() {
		var me = this;
		var records = me.getSelectionModel().getSelection();
		if (records.length > 0) {
			me.openUpdateWindow(records);
		} else {
			alert('Please select records to update');
		}
	},
	
	/**
	* Uses the App.ux.data.Actionable mixin to update one or more records
	* called from App.ux.window.UpdateWindow
	*/
	updateAllRecords: function(records) {
		var me = this;
	
		me.setLoading('Updating..');
		// call the actionable mixin in the store
		me.getStore().doAction('update_all', records,
			{
				success: function(operation){
					me.setLoading(false);
					for(var i=0; i < records.length; i++) {
						records[i].commit();
					}
				},
				failure: function(operation){
					me.setLoading(false);
					for(var i=0; i < records.length; i++) {
						records[i].reject();
					}
					alert('Could not update, changes rolled back');
				}
		});
	},
	
	/**
	* Opens edit window with new or existing record
	* called newRecord() and editRecord()
	*/
	openEditWindow: function(recordId) {
		var me = this;
		
		if (me.editWindow != '') {
			var title = recordId > 0 ? 'Update '+me.entitySingular : 'Add '+me.entitySingular;
			var editWindow = Ext.create(me.editWindow, {
				title: title,
				gridId: me.id,
				recordId: recordId
			})
		
			editWindow.show();
		}
	},

	/**
	* Opens update window to update all
	*/
	openUpdateWindow: function(records) {
		var me = this;
		
		if (me.updateWindow != '') {
			var updateWindow = Ext.create(me.updateWindow, {
				gridId: me.id,
				selectedRecords: records
			})
		
			updateWindow.show();
		}
	},

	/**
	* calls the App.ux.data.Updateable model mixin to update grid record with passed config 
	* called App.ux.window.EditWindow.saveRecord()
	*/
	updateRecord: function(recordId, updateRecord, response) {
		var me = this;

		// add or update the edited record
		if (recordId < 1) {
			me.getStore().load();
		} else {
			var record = me.store.getById(recordId);
			if (record) {
				record.updateModel(updateRecord);
			}
		}
	},
	
	/**
	* Loads the grid store and handles the initial section completed display
	*/
	load: function() {
		var me = this;
		
		me.store.guaranteeRange(0, 199);	
	}
});