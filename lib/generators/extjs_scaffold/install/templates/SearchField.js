/**
 * @author Mark H Winkler
 * @class App.ux.form.field.SearchField
 * @extends Ext.form.field.Trigger
 * <p>Extends Triggers with an assoicated data store,
 * passing the entered text as an extra parameter to the store
 * For example:</p>
 * <pre><code>
		Ext.create('Ext.grid.Panel', {
			dockedItems: [{
				xtype: 'toolbar',
				dock: 'top',
				items: [{
					xtype: 'searchfield',
					store: Ext.data.StoreManager.lookup('store')
					}]
			}]
		});

		Ext.create('App.ux.form.field.SearchField', {
			store: Ext.data.StoreManager.lookup('store')
		});
	</code></pre>
*/
Ext.define('<%= app_name %>.ux.form.field.SearchField', {
	extend: 'Ext.form.field.Trigger',
	alias: 'widget.searchfield',

	trigger1Cls: 'x-form-search-trigger',
	trigger2Cls: 'x-form-clear-trigger',
	emptyText: '',
	width: 180,
	
	/**
	* @cfg {store} store
	* The associated data store to receive query
	*/
	store: '',
	
	/**
	* @cfg {String} queryParam
	* The query param name sent to store
	* (defaults to <tt>query</tt>)
	*/
	queryParam: 'query',

	initComponent: function(){
		this.callParent(arguments);
		this.on('specialkey', this.checkEnterKey, this);
	},

	onRender: function() {
		this.callParent(arguments);
		this.triggerEl.elements[1].hide();
	},
	
	// Handle enter key presses, execute the search if the field has a value
	checkEnterKey: function(field, e) {
		var value = this.getValue();
		if (e.getKey() === e.ENTER) {
			this.search();
		}
	},

	onTrigger1Click: function() {
		this.search();
	},

	onTrigger2Click: function() {
		this.clearSearch();
	},

	search: function() {
		var me = this;
		me.triggerEl.elements[1].show();
		var v = this.getRawValue();
		if (v.length < 1){
			me.clearSearch();
			return;
		}
		if (me.store) {
			var query = {}
			query[me.queryParam] = v;
			Ext.apply(me.store.proxy.extraParams, query); 
			me.store.load();
		}
	},

	clearSearch: function() {
		var me = this;
		me.triggerEl.elements[1].hide();
		me.setValue('');
		if (me.store) {
			var query = {}
			query[me.queryParam] = '';
			Ext.apply(me.store.proxy.extraParams, query); 
			me.store.load();
		}
	}
});
