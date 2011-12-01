/**
 * @author Mark H Winkler
 * @mixin App.ux.data.Actionable
 * Required use: class using App.ux.data.proxy.Rails
 * 
 * Adds doAction function to class - convenience method for rails proxy doAction
 *  allowing a non rest action to be passed
 *  to Rails (e.g. /teams/delete_all.json).
 *
 * The actionName must exist in the proxy under the 'addActions' config which stores 
 *  the METHOD (GET, POST, PUT, DELETE) and Collection (true = collection or false = member)
 * 
 * params:
 * actionName (string) - required - name of action added to proxy
 * records (array) - optional - array of Model Records
 * options (object) - optional - options to associate with action including callback
 *
 */

Ext.define('<%= app_name %>.ux.data.Actionable', {
	doAction: function(action, records, options) {
		var me = this;
		// call doAction in proxy
		me.getProxy().doAction(action, records, options);
		return me;
	}
});