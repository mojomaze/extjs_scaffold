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
	isReadOnly: false,
	multiSelect: false,

	// Use a PagingGridScroller
	verticalScrollerType: 'paginggridscroller',
	invalidateScrollerOnRefresh: false,
	//disableSelection: true,

	enableColumnHide: false,
	enableColumnMove: false,
	enableColumnResize: false,

	height: 600,
	width: 800,

	preventHeader: true,
	frame: true,

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
	
	// enabling top bar buttons by default
	enableRemoteSearch: false,
	enableEditRecord: true,
	enableAddRecord: false,
	enableDeleteRecord: false,
	enableStoreReload: false,

	// hides the bottom bar
	hideBottomToolbar: false,

	// menu to populate in actions
	actionsMenu: '',
	// menu to populate in exports
	exportsMenu: '',

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

		if (!me.isReadOnly) {
			if ( me.enableEditRecord ) {
				topitems.push({
					text: 'EDIT '+this.entityPlural,
			    tooltip: 'Click to update '+this.entitySingular,
					iconCls: 'edit',
					cls: 'list-edit-btn',
					scope: me,
					handler: me.onEditBtnClick
				});
				topitems.push( '-' );
			}

			if ( me.enableAddRecord ) {
				topitems.push({ 
					text: 'Add New Records',
					tooltip: 'Add new '+this.entitySingular,
					iconCls: 'add',
					scope: me,
					handler: me.newRecord 
				});
				topitems.push( '-' );
			}
		
			if ( me.enableDeleteRecord ) {
				topitems.push({
					text: 'Delete Records',
					tooltip: 'Delete selected records',
					iconCls: 'remove',
					scope: me,
					handler: me.deleteRecords
				});
				topitems.push( '-' );
			}
			if (me.actionsMenu != '') {
				topitems.push({
					text: 'Actions',
					tooltip: 'Perform actions on selected '+this.entityPlural,
					iconCls: 'cog',
					menu: me.actionsMenu
				});
			}
				
			if (me.exportsMenu != '') {
				topitems.push({
					text: 'Export',
					tooltip: 'Run Exports',
					iconCls: 'export',
					menu: me.exportsMenu
				});
			}
			
		} else {
			topitems.push({xtype: 'tbtext', cls: 'readonly-text', text: me.entitySingular+' (Read Only)'});
		}
		topitems.push('->');
    topitems.push({xtype: 'tbtext', itemId: 'sectionCompleted', cls: 'section-completed', hidden: true, text: 'Section Completed'});
		
		toolbars.push({
			xtype: 'toolbar',
			itemId: 'toptoolbar',
		  dock: 'top',
			items: topitems
		});
		
		if (!me.hideBottomToolbar) {
			toolbars.push({
				xtype: 'scrollingtoolbar',
				itemId: 'bottomtoolbar',
				store: me.store,
				dock: 'bottom',
				displayInfo: true,
				displayReload: me.enableStoreReload
			});
		}	
		
		return toolbars;
	},
	
	/**
	* Grid double click handler
	*/
	onDblClick: function(view, record, item, index, event, options) {
		if (!this.isReadOnly) {
			this.editRecord(record);
		}
	},
	
	/**
	* handler for Edit Button
	* Finds selection or selects first record
	* Calls editRecord() with record
	*/
	onEditBtnClick: function() {
		var record = null;
		
		if (this.store.getCount() > 0) {
			selModel = this.getSelectionModel();
			selection = selModel.getSelection();
			record = selection[0];
			if (!record) { // edit first rec if none selected
				record = this.store.getAt(0);
				selModel.select(0);
			}
		}
		if (record) {
			this.editRecord(record);
		}
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
								var result = Ext.JSON.decode(operation.response.responseText);
								var areaCompleted = result.areaCompleted;
								var sectionCompleted = result.sectionCompleted;
								
								// update the area (grid section complete)
								me.toggleAreaCompleted( areaCompleted );

								// update the left nav section completed
								me.toggleSectionCompleted( sectionCompleted );
							},
							failure: function(record, operation){
								alert('Could not delete, changes rolled back');
							}
					});
				};
			});
		}
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
		
		// since grid is not reloaded after load
		// update the area (grid section complete)
		me.toggleAreaCompleted( response.areaCompleted );
		
		// update the left nav section completed
		me.toggleSectionCompleted( response.sectionCompleted );
	},
	
	/**
	* Loads the grid store and handles the initial section completed display
	*/
	load: function() {
		var me = this;
		
		me.store.guaranteeRange(0, 199,
		    function(records) {
		    	// message property = areaCompleted
					var proxy = me.store.getProxy();
					var reader = proxy.getReader();
					var rawData = reader.rawData;
					var completed = rawData.areaCompleted;
					me.toggleAreaCompleted(completed);
		    },
				this
		);	
	},

	/**
	* Shows or hides the section-completed text based on the nav completed class
	*/	
	toggleAreaCompleted: function(completed){
		var me = this;
		
		var completed = completed || false;
		var completedText = me.getDockedComponent('toptoolbar').getComponent('sectionCompleted');
		
		if ( completed ){
				completedText.show();
		} else {
				completedText.hide();
		}
	},
	
	/**
	* Adds or removes the completed css from left navigation
	*/
	toggleSectionCompleted: function(completed) {
		var me = this;
		
		var completed = completed || false;
		var nav = Ext.get('sidebar');
		if ( nav ) {
			var selected = nav.down('.selected');	
		} 
		
		if ( selected ) {
			if ( completed ) {
				selected.addCls('completed');
			} else {
				selected.removeCls('completed');
			}
		}
	}
});