/**
 * @author Mark H Winkler
 * @class App.ux.toolbar.FormPaging
 * @extends Ext.toolbar.FormPaging
 * <p>Extends toolbar.Toolbar</p>
 * <p>Stripped down version of Ext.toolbar.Paging that shows total recs from store</p>
*/
Ext.define('App.ux.toolbar.FormPaging', {
    extend: 'Ext.toolbar.Toolbar',
    alias: 'widget.formpagingtoolbar',
    requires: ['Ext.toolbar.TextItem'],
    /**
     * @cfg {String} displayMsg
     * The paging status message to display 
     */
    displayMsg : 'Displaying Item {0} of {1}',
    /**
     * @cfg {String} emptyMsg
     * The message to display when no records are found (defaults to 'No data to display')
     */
    emptyMsg : 'No data to display',
		/**
     * @cfg {integer} currentRecordIndex
     * The index of the currently selected record
     */
		currentRecordIndex: -1,
    /**
     * Gets the standard paging items in the toolbar
     * @private
     */
    getPagingItems: function() {
        var me = this;
        
        return [
					{xtype: 'tbtext', itemId: 'displayItem'}
					,'-',
					{
						itemId: 'prev',
						iconCls: 'prevpage',
						text: '<b>Previous Item</b>',
						handler: me.movePrevious,
            scope: me,
						tooltip: 'Save and Move to Previous Item'
					}
					,'-',
					{
						itemId: 'next',
						iconCls: 'nextpage',
						iconAlign: 'right',
						text: '<b>Next Item</b>',
						handler: me.moveNext,
            scope: me,
						tooltip: 'Save and Move to Next Item'
					}
					,'-',
					{xtype: 'tbtext', itemId: 'displayMessage'}
				];
    },

    initComponent : function(){
				var me = this;
				me.items = me.getPagingItems();
        
				me.callParent();
				
				me.on('afterlayout', me.onLoad, me, {single: true});
        
				me.bindStore(me.store || 'ext-empty-store', true);
    },

    // private
    updateInfo : function(){
        var me = this,
          displayItem = me.child('#displayItem'),
          store = me.store,
          totalCount = store.getTotalCount(),
					grid = Ext.getCmp(me.ownerCt.gridId),
					selModel = grid.getSelectionModel(),
					selection = selModel.getSelection(),
					record = selection[0];
					
				if (!record) { // edit first rec if none selected
					record = this.store.getAt(0);
					selModel.select(0);
				}
				
				// get the rownumberer value for selected
				var nodes = grid.getView().getSelectedNodes();
				var first = nodes[0].firstChild;
				var el = first.firstChild;
				var val = el.textContent;
				
				// update the current record index
				me.currentRecordIndex = store.indexOf( record );
				// use the rownumberer if enabled
				if (parseInt(val) > 0) {
					recordNumber = val;
				} else { // or use the index if no rownumberer
					recordNumber = me.currentRecordIndex + 1;
				}
				
        if (displayItem) {
            count = store.getCount();
            if (count === 0) {
                msg = me.emptyMsg;
            } else {
                msg = Ext.String.format(
										me.displayMsg,
										recordNumber,
                    totalCount
                );
            }
            displayItem.setText(msg);
            me.doComponentLayout();

						// handle previous next disable/enable
						if (recordNumber == 1 ){
							me.getComponent('prev').disable();
						} else {
							me.getComponent('prev').enable();
						}
						
						if (recordNumber == totalCount ){
							me.getComponent('next').disable();
						} else {
							me.getComponent('next').enable();
						}
        }
    },

		// private
    onLoad : function(){
        var me = this;
            
        if (!me.rendered) {
            return;
        }
        me.updateInfo();
    },
    
    /**
     * Binds the paging toolbar to the specified {@link Ext.data.Store}
     * @param {Ext.data.Store} store The store to bind to this toolbar
     * @param {Boolean} initial (Optional) true to not remove listeners
     */
    bindStore : function(store, initial){
        var me = this;
        
        if (!initial && me.store) {
            if(store !== me.store && me.store.autoDestroy){
                me.store.destroy();
            }
            if(!store){
                me.store = null;
            }
        }
        if (store) {
            store = Ext.data.StoreManager.lookup(store);
        }
        me.store = store;
    },

    // private
    onDestroy : function(){
        this.bindStore(null);
        this.callParent();
    },

		movePrevious: function(){
			var me = this;
			index = me.currentRecordIndex - 1;
			me.handleMove(index);
			
		},
		
		moveNext: function(){
			var me = this,
			editWindow = me.ownerCt,
			grid = Ext.getCmp(editWindow.gridId);
			index = me.currentRecordIndex + 1;
			me.handleMove(index);
			grid.scrollByDeltaY(12);
		},
		
		handleMove: function(index) {
			var me = this,
				editWindow = me.ownerCt,
				grid = Ext.getCmp(editWindow.gridId),
				selModel = grid.getSelectionModel();
			
			// disable move buttons until finished - re-enabled in updateInfo()
			me.getComponent('prev').disable();
			me.getComponent('next').disable();
			
			// find the recod in the store by index
			record = me.store.getAt(index);
			// have the store load more records if necessary
			if (record ) {
				// select it
				selModel.select(record);
				// load it
				notSaved = editWindow.moveRecord(record.getId());
				// the editwindow calls updateInfo after save
				// so prev & next remain disabled until after save
				// if (notSaved) {
				// 					// clear the saved record message
				// 					me.child("#displayMessage").setText('');
				// 					// update toolbar
				// 					me.updateInfo();
				// 				}
		 	}
		},
		
		updateAfterMoveLoad: function(msg) {
			var me = this;
			
			me.child("#displayMessage").setText(msg);
			// update toolbar
			me.updateInfo();
		}
});

