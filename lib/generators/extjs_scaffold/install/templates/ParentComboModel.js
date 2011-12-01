/**
 * @author Mark H Winkler
 * @class App.model.ParentCombo
 * @extends Ext.data.Model
 * <p>Create a reusable model for App.ux.form.field.ParentCombo field</p>
*/
Ext.define('<%= app_name %>.model.ParentCombo', {
	extend: 'Ext.data.Model',

	fields: [
		{name: 'id'},
		{name: 'name'}
	]
});
