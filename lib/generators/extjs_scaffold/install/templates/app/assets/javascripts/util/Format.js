/**
 * @singleton
 * 
 * application wide config and methods
 *
 */
(function() {
  Ext.ns('App.util');
	
	App.util.Format = {};
  var AppUtilFormat = App.util.Format;



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
		   	return v ? '<img src="/images/app/tick.png">' : '';
			}
		}
		
	});	
})();