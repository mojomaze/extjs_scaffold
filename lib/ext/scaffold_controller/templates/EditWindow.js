Ext.define('App.view.<%= singular_table_name %>.EditWindow', {
	extend: 'App.ux.window.EditWindow',
	requires: ['App.view.<%= singular_table_name %>.Form'],
	
	baseUrl: '/<%= plural_table_name %>',
	model: 'App.model.<%= singular_table_name.capitalize %>',
	formItemId: '<%= singular_table_name %>Form',
	
	initComponent: function() {
		this.items = this.buildItems();
		this.callParent(arguments);
	},
	
	buildItems: function() {
		var me = this;
		var url = this.recordId > 0 ? me.baseUrl+'/'+this.recordId : me.baseUrl;
		var method = this.recordId > 0 ? 'PUT' : 'POST';
		return [
			{
				xtype: '<%= singular_table_name %>form',
				itemId: me.formItemId,
				url: url,
				method: method,
				waitMsgTarget: true
			}
		];
	}
});