/**
 * @author Adapted from Ext.ux.form.SearchField example
 * http://www.sencha.com/
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

	trigger1Cls: 'x-form-clear-trigger',
	trigger2Cls: 'x-form-search-trigger',

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
		this.triggerEl.elements[0].setDisplayed('none');
	},

	// Handle enter key presses, execute the search if the field has a value
	checkEnterKey: function(field, e) {
		var value = this.getValue();
		if (e.getKey() === e.ENTER) {
			this.search();
		}
	},

	onTrigger2Click: function() {
		this.search();
	},

	onTrigger1Click: function() {
		this.clearSearch();
	},

	search: function() {
		var me = this;
		me.triggerEl.elements[0].setDisplayed('block');
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
		me.doComponentLayout();
	},

	clearSearch: function() {
		var me = this;
		me.triggerEl.elements[0].setDisplayed('none');
		me.setValue('');
		if (me.store) {
			var query = {}
			query[me.queryParam] = '';
			Ext.apply(me.store.proxy.extraParams, query); 
			me.store.load();
		}
		me.doComponentLayout();
	}
});