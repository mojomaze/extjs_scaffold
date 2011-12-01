/**
 * @author Mark H Winkler
 * @class App.ux.toolbar.Scrolling
 * @extends Ext.toolbar.Toolbar
 * <p>Extends toolbar.Toolbar</p>
 * <p>Stripped down version of Ext.toolbar.Paging that shows total recs from store</p>
*/
Ext.define('<%= app_name %>.ux.toolbar.Scrolling', {
	extend: 'Ext.toolbar.Toolbar',
	alias: 'widget.scrollingtoolbar',
	requires: ['Ext.toolbar.TextItem'],
	/**
	* @cfg {String} displayMsg
	* The paging status message to display
	*/
	displayMsg : 'Total: {0}',
	/**
	* @cfg {String} emptyMsg
	* The message to display when no records are found (defaults to 'No data to display')
	*/
	emptyMsg : 'No data to display',
	/**
	* @cfg {String} refreshText
	* The quicktip text displayed for the Refresh button (defaults to <tt>'Refresh'</tt>).
	* <b>Note</b>: quick tips must be initialized for the quicktip to show.
*/
	refreshText : 'Refresh',
	/**
	* @cfg {boolean} displayReload
	* add reload button to toolbar
*/
	displayReload: false,

	initComponent : function(){
		var me = this;
		me.items = [];

		if (me.displayReload) {
			me.items.push({
				tooltip: 'Refresh',
				iconCls: 'x-tbar-loading',
				scope: me,
				handler: me.reload
			});
		}

		if (me.displayInfo) {
			me.items.push('->');
			me.items.push({xtype: 'tbtext', itemId: 'displayItem'});
		}

		me.callParent();

		me.on('afterlayout', me.onLoad, me, {single: true});

		me.bindStore(me.store || 'ext-empty-store', true);
	},

	// private
	updateInfo : function(){
		var me = this,
		displayItem = me.child('#displayItem'),
		store = me.store,
		totalCount = store.getTotalCount();

		if (displayItem) {
			count = store.getCount();
			if (count === 0) {
				msg = me.emptyMsg;
			} else {
				msg = Ext.String.format(
					me.displayMsg,
					totalCount
				);
			}
			displayItem.setText(msg);
			me.doComponentLayout();
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

	// private
	onLoadError : function(){
		if (!this.rendered) {
			return;
		}
		this.child('#refresh').enable();
	},

	/**
	* Refresh the current page, has the same effect as clicking the 'refresh' button.
	*/
	// doRefresh : function(){
	//      var me = this,
	//          current = me.store.currentPage;
	//      
	//      if (me.fireEvent('beforechange', me, current) !== false) {
	//          me.store.loadPage(current);
	//      }
	//  },

	/**
	* Binds the paging toolbar to the specified {@link Ext.data.Store}
	* @param {Ext.data.Store} store The store to bind to this toolbar
	* @param {Boolean} initial (Optional) true to not remove listeners
	*/
	bindStore : function(store, initial){
		var me = this;

		if (!initial && me.store) {
			if (store !== me.store && me.store.autoDestroy) {
				me.store.destroy();
			} else {
				me.store.un('load', me.onLoad, me);
				me.store.un('exception', me.onLoadError, me);
			}
			if (!store) {
				me.store = null;
			}
		}
		if (store) {
			store = Ext.data.StoreManager.lookup(store);
			store.on({
				scope: me,
				load: me.onLoad,
				exception: me.onLoadError
			});
		}
		me.store = store;
	},

	// private
	onDestroy : function(){
		this.bindStore(null);
		this.callParent();
	},

	updateTotal: function(total){
		var me = this,
			displayItem = me.child('#displayItem');

		if (displayItem) {
			count = total;
			if (count === 0) {
				msg = me.emptyMsg;
			} else {
				msg = Ext.String.format(
					me.displayMsg,
					count
				);
			}
			displayItem.setText(msg);
			me.doComponentLayout();
		}
	},

	reload: function() {
		var me = this;
		me.store.load();
	}
});
