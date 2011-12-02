Ext.define('App.view.<%= singular_table_name %>.Grid', {
	extend: 'App.ux.grid.Panel',
	alias: 'widget.<%= singular_table_name %>grid',
	requires : ['App.store.<%= plural_table_name.capitalize %>','App.view.<%= singular_table_name %>.EditWindow'],
	
	title: '<%= plural_table_name.capitalize %>',
	
	entitySingular: '<%= singular_table_name.capitalize %>',
	entityPlural: '<%= plural_table_name.capitalize %>',
	editWindow: 'App.view.<%= singular_table_name %>.EditWindow',
	
	initComponent: function() {
		this.store = App.store.<%= plural_table_name.capitalize %>;
		this.columns = this.buildColumns();
		this.callParent(arguments);
	},
	
	buildColumns: function() {
		return [
			<% attributes.each_with_index do |attribute, index| %>
				<%= index > 0 ? ',' : '' %>{<%= create_ext_column(attribute) -%>}	
			<% end %>
		];
	}
});