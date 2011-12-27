/**
 * @singleton
 * 
 * application wide formatting
 *
 */
(function() {
	Ext.ns('<%= app_name %>.util');
	
	<%= app_name %>.util.Format = {};
	var AppUtilFormat = <%= app_name %>.util.Format;

	Ext.apply(AppUtilFormat, {
		/**
		* Returns a date as set format - used to control application wide grid dates
		* @return {Function} The date formatting function
		*/
		dateRenderer : function() {
			return function(v) {
				return Ext.util.Format.date(v, 'm/d/Y');
			}
		},
		
		/**
		* Returns an image or empty string - used to control application wide grid booleans
		* @return {Function} The boolean formatting function
		*/
		booleanRenderer: function() {
			return function(v) {
				return v ? '<img src="/images/extjs_scaffold/tick.png">' : '';
			}
		}
	});	
})();