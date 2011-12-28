Ext.define('<%= app_name %>.view.<%= singular_table_name %>.Grid', {
	extend: '<%= app_name %>.ux.grid.Panel',
	alias: 'widget.<%= singular_table_name %>grid',
	requires : ['<%= app_name %>.store.<%= plural_table_name.capitalize %>'],
	
	title: '<%= plural_table_name.capitalize %>',
	
	entitySingular: '<%= singular_table_name.capitalize %>',
	entityPlural: '<%= plural_table_name.capitalize %>',
	editWindow: '<%= app_name %>.view.<%= singular_table_name %>.EditWindow',
	updateWindow: '<%= app_name %>.view.<%= singular_table_name %>.UpdateWindow',
	
	initComponent: function() {
		this.store = <%= app_name %>.store.<%= plural_table_name.capitalize %>;
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