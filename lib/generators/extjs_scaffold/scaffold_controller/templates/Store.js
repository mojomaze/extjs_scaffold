<% 
	#default sort to first attribute
	sort_column = attributes.first ? attributes.first.name : ''
	if attributes.first && attributes.first.reference?
		sort_column += '_name'
	end -%>
Ext.define('App.store.<%= plural_table_name.capitalize %>', {
	extend: 'Ext.data.Store',
	mixins: {
		actionable: 'App.ux.data.Actionable'
	},
	
	singleton: true,
	requires: ['App.model.<%= singular_table_name.capitalize %>'],
	model: 'App.model.<%= singular_table_name.capitalize %>',
	
	storeId: '<%= singular_table_name %>Store',
	autoLoad: false,
	remoteSort: true,
	pageSize: 20,
	sorters: [
		{
			property: '<%= sort_column %>',
			direction: 'ASC'
		}
	]
});