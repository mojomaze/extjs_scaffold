/**
 * @author Mark H Winkler
 * @class App.ux.form.Panel
 * @extends Ext.form.Panel
 * <p>Extends form.Panel to establish form config defaults.</p>
*/
Ext.define('App.ux.form.Panel', {
	extend: 'Ext.form.Panel',
	
	bodyPadding: 5,

  // Fields will be arranged vertically, stretched to full width
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
		this.dockedItems = this.buildDockedItems();
		this.callParent(arguments);
		this.getForm().trackResetOnLoad = true;
	},
	
	buildDockedItems: function() {
		return [{
			xtype: 'toolbar',
			dock: 'bottom',
			items: [	
					{ xtype: 'tbtext', text: '', cls:'required-icon' },
					{ xtype: 'tbtext', text: '<span style="color:red;">Required Fields</span>' }
				]
		}]
	}
	
});