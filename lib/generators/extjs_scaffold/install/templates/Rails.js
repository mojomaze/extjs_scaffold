/**
 * @author Mark H Winkler
 * @class App.ux.data.proxy.Rails
 * @extends Ext.data.proxy.Rest
 * 
 * Rails proxy extends Rest proxy to allow non-rest actions to be used.
 * Example: 
 *   POST /teams/delete_all.json (collection)
 *   POST /teams/1/send_note.json (member)
 */
Ext.define('<%= app_name %>.ux.data.proxy.Rails', {
	extend: 'Ext.data.proxy.Rest',
	alias : 'proxy.rails',

	/**
	* @config: addActions
	* config of allowed actions
	* 
	* addActions: {
	*		destroy_all: {
	*			method: 'POST',
	*			collection: true
	*		}
	* }
	*/
	addActions: {},

	/**
	* @function: doAction(action, records, options)
	* allows a non rest action to be passed
	*  to Rails (e.g. /teams/delete_all.json).
	*
	* The format and fields sent are determined in the proxy writer.
	*  the following will send .json => player [{id: 1},{id:2}]
	*		writer: {
	*			type: 'json',
	*			root: 'player',
	*			encode: true,
	*			writeAllFields: false,
	*			allowSingle: false
	*		}
	*
	* The actionName must exist in the proxy under the 'addActions' config which stores 
	*  the METHOD (GET, POST, PUT, DELETE) and Collection (true = collection or false = member)
	* 
	* When collection = false the record id is sent in query string: /teams/1/change_something.json
	*
	* params:
	* action (string) - required - name of action added to proxy
	* records (array) - optional - array of Model Records
	* options (object) - optional - options to associate with action including callback
	*
	*/
	doAction: function(action, records, options) {
		// create options object if not passed
		options = Ext.apply({}, options);
		
		// declare config vars
		var me = this,
		scope  = options.scope || me,
		operation,
		callback;
		
		// create records array if not passed
		records = records || [];
		
		// concat params into options object
		Ext.apply(options, {
			records: records,
			action : action
		});

		// create a new operation to send to the proxy
		operation = Ext.create('Ext.data.Operation', options);
		
		// create a callback chain for the action
		callback = function(operation) {
			if (operation.wasSuccessful()) {
				Ext.callback(options.success, scope, [operation]);
			} else {
				Ext.callback(options.failure, scope, [operation]);
			}
			Ext.callback(options.callback, scope, [operation]);
		};
		
		// call doRequest
		me.doRequest(operation, callback, me);
		return me;
	},
	
	/**
	* @function: getActionMethod(request)
	* Returns the method from addActions config
	* called from getMethod
	*/
	getActionMethod: function(request) {
		var action = this.addActions[request.action];
		if (action) {
			return action['method'] || 'POST';
		}
		return null;
	},
	
	/**
	* Extending Ext.data.proxy.Ajax.getMethod() to return addActions
	*/
	getMethod: function(request) {
		return this.callParent(arguments) || this.getActionMethod(request);
	},

	/**
	* Overriding buildUrl - incorporates the {@link #appendId} and {@link #format} options from Rest proxy
	* uses addActions object to append custom actions sent to controller
	* cache buster string from Server proxy is appended instead of calling parent
	*/
	buildUrl: function(request) {
		var me = this,
		operation = request.operation,
		records = operation.records || [],
		record = records[0],
		format = me.format,
		url = me.getUrl(request),
		id = record ? record.getId() : operation.id;
		
		// clear id if addActions type is collection
		if (me.addActions[request.action]) {
			if (me.addActions[request.action].collection) {
				id = null;
			}
		}

		if (me.appendId && id) {
			if (!url.match(/\/$/)) {
				url += '/';
			}
			url += id;
		}

		// if part of custom actions, add to url
		if (me.addActions[request.action]) {
			if (!url.match(/\/$/)) {
				url += '/';
			}
			url += request.action;
		} 
		
		if (format) {
			if (!url.match(/\.$/)) {
				url += '.';
			}
			url += format;
		}

		request.url = url;
		
		// adding cache buster string from Ext.data.proxy.Server
		if (me.noCache) {
			url = Ext.urlAppend(url, Ext.String.format("{0}={1}", me.cacheString, Ext.Date.now()));
		}
		return url;
	}
});