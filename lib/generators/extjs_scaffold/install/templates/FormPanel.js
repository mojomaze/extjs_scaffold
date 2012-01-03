/**
 * @author Mark H Winkler
 * @class App.ux.form.Panel
 * @extends Ext.form.Panel
 * <p>Extends form.Panel to establish form config defaults.</p>
*/
Ext.define('<%= app_name %>.ux.form.Panel', {
	extend: 'Ext.form.Panel',

	bodyPadding: 5,

	defaults: {
		style: 'padding-bottom: 2px',
		labelStyle: 'padding-right: 5px',
		labelAlign: 'right',
		labelWidth: 120,
		width: 400
	},

	// The fields
	defaultType: 'textfield',

	initComponent: function() {
		this.callParent(arguments);
		this.getForm().trackResetOnLoad = true;
	}
});