<% 
	#default sort to first attribute
	sort_column = attributes.first ? attributes.first.name : ''
	if attributes.first && attributes.first.reference?
		sort_column += '_name'
	end -%>
Ext.define('<%= app_name %>.store.<%= plural_table_name.capitalize %>', {
	extend: 'Ext.data.Store',
	mixins: {
		actionable: '<%= app_name %>.ux.data.Actionable'
	},
	
	singleton: true,
	requires: ['<%= app_name %>.model.<%= singular_table_name.capitalize %>'],
	model: '<%= app_name %>.model.<%= singular_table_name.capitalize %>',
	
	storeId: '<%= singular_table_name %>Store',
	autoLoad: false,
	remoteSort: true,
	buffered: true,
	pageSize: 200,
	sorters: [
		{
			property: '<%= sort_column %>',
			direction: 'ASC'
		}
	]
});