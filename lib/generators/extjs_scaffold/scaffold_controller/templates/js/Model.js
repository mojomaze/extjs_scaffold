Ext.define('<%= app_name %>.model.<%= singular_table_name.capitalize %>', {
	extend: 'Ext.data.Model',
	mixins: {
		updateable: '<%= app_name %>.ux.data.Updateable'
	},
	
	fields: [
		{ name: 'id', type: 'int' }
		<% attributes.each_with_index do |attribute, index| %>
			,{<%= create_ext_record(attribute) -%>}
			<% if attribute.reference? -%>
      ,{name: '<%= attribute.name %>_id'}
			<% end %>
		<% end %>
	],
	
	proxy: {
		type: 'rails',
		url: '/<%= plural_table_name %>',
		format: 'json',
		addActions: {
			destroy_all: {
				method: 'POST',
				collection: true
			},
			update_all: {
				method: 'POST',
				collection: true
			}
		},
		reader: {
			type: 'json',
			root: '<%= singular_table_name %>'
		},
		writer: {
			type: 'json',
			root: '<%= singular_table_name %>',
			encode: true,
			writeAllFields: true,
			allowSingle: false
		}
	}
});
