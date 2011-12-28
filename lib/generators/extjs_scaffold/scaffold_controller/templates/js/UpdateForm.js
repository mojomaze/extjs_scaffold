Ext.define('<%= app_name %>.view.<%= singular_table_name %>.UpdateForm', {
	extend: '<%= app_name %>.ux.form.Panel',
	alias: 'widget.<%= singular_table_name %>updateform',
	
	initComponent: function() {
		this.items = this.buildItems();
		this.callParent(arguments);
	},
	
	buildItems: function() {
		return [
			<% attributes.each_with_index do |attribute, index| %>
				<%= index > 0 ? ',' : '' %> <%= create_ext_updateformfield(attribute) -%>
			<% end %>
		];
	}
});