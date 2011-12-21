Ext.define('<%= app_name %>.store.<%= singular_table_name.capitalize %><%= @reference_attribute.name.capitalize.pluralize %>', {
	extend: 'Ext.data.Store',

	singleton: true,
	requires: ['<%= app_name %>.model.<%= @reference_attribute.name.capitalize %>'],
	model: '<%= app_name %>.model.<%= @reference_attribute.name.capitalize %>',
	
	storeId: '<%= singular_table_name.capitalize %><%= @reference_attribute.name.capitalize.pluralize %>',
	autoLoad: false,
	remoteSort: true,
	sorters: [
		{
			property: '<%= reference_field(@reference_attribute) %>',
			direction: 'ASC'
		}
	],
	
	proxy: {
		type: 'rest',
		url: '/<%= @reference_attribute.name.pluralize %>',
		format: 'json',
		reader: {
			type: 'json',
			root: '<%= @reference_attribute.name %>'
		}
	}
});
