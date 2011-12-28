Ext.define('<%= app_name %>.view.<%= singular_table_name %>.EditForm', {
	extend: '<%= app_name %>.ux.form.Panel',
	alias: 'widget.<%= singular_table_name %>form',
	
	initComponent: function() {
		this.items = this.buildItems();
		this.callParent(arguments);
	},
	
	buildItems: function() {
		return [
			<% attributes.each_with_index do |attribute, index| %>
				<%= index > 0 ? ',' : '' %> <%= create_ext_formfield(attribute) -%>
			<% end %>
		];
	}
});