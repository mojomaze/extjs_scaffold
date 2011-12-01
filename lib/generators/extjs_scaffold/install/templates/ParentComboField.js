/**
 * @author Mark H Winkler
 * @class App.ux.form.field.ParentCombo
 * @extends Ext.form.field.ComboBox
 * <p>Extends ComboBox to create a base class for parent 
 * record associations in detail forms. Uses valueField = 'id', displayField = 'name</p>
 * <pre><code>
		Ext.create('Ext.form.Panel', {
			items: [{
				xtype: 'parentcombo',
				store: Ext.data.StoreManager.lookup('store')
			}]
		});

		Ext.create('App.ux.form.field.ParentCombo', {
    	store: Ext.data.StoreManager.lookup('store')
		});
		</code></pre>
*/
Ext.define('<%= app_name %>.ux.form.field.ParentCombo', {
	extend: 'Ext.form.field.ComboBox',
	alias: 'widget.parentcombo',

	valueField: 'id',
	displayField:'name',
	typeAhead: false,
	selectOnFocus: true,
	loadingText: 'Searching...',
	hideTrigger:true,
	forceSelection: true,
	allowBlank: true,
	minChars: 2,
	lazyRender: true,
	emptyText: 'type at least 2 characters from name',
	width: 350,
	listWidth: 350,
	listClass: 'x-combo-list-small',
	triggerClass:'x-form-search-trigger'
});