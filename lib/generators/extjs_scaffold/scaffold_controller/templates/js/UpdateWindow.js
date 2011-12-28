Ext.define('<%= app_name %>.view.<%= singular_table_name %>.UpdateWindow', {
	extend: '<%= app_name %>.ux.window.UpdateWindow',
	
	model: '<%= app_name %>.model.<%= singular_table_name.capitalize %>',
	formItemId: '<%= singular_table_name %>UpdateForm',
	
	initComponent: function() {
		this.items = this.buildItems();
		this.callParent(arguments);
	},
	
	buildItems: function() {
		var me = this;
		return [
			{
				xtype: '<%= singular_table_name %>updateform',
				itemId: me.formItemId
			}
		];
	}
});