/**
 * @author Mark H Winkler
 * @class App.ux.grid.Embedded
 * @extends App.ux.grid.Panel
 * <p>Extends ux.grid.Panel so grid embedded in form updates to local store only
*      and does not communicate with remote server</p>
*/
Ext.define('App.ux.grid.Embedded', {
	extend: 'App.ux.grid.Panel',
	
	/**
  * removes records from local store
  */
	deleteRecords: function() {
		var me = this;
		var records = me.getSelectionModel().getSelection();
		if (records.length > 0) {
			// confirm that records should be deleted
			var entity = records.length > 1 ? me.entityPlural : me.entitySingular;
			Ext.Msg.confirm('Warning','Delete '+records.length+' '+entity+'?', function(btn){
				if(btn=='yes'){
					// just remove records from store
					me.getStore().remove(records);
				};
			});
		}
	},
	
	/**
  * Opens edit window with new record
	* called from top toolbar Add button
	* Using model instead of recordId for embedded form
  */
	newRecord: function() {
		this.openEditWindow(null);
	},
	
	/**
     * Opens edit window with passed record
	 * called from onDblClick handler
     */
	editRecord: function(record) {
		if (record) { // edit the record
			this.openEditWindow(record);
		}
	},
	
	/**
     * Opens edit window with new or existing record
	 * called newRecord() and editRecord()
     */
	openEditWindow: function(record) {
		var me = this;
		var recordId = me.getStore().indexOf(record);
		var title = recordId > -1 ? 'Update '+me.entitySingular : 'Add '+me.entitySingular;
		var editWindow = Ext.create(me.editWindow, {
			title: title,
			gridId: me.id,
			recordId: recordId,
			record: record
		})
		
		editWindow.show();
	}
});