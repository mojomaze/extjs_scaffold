Ext.application({
	name: 'App',
	autoCreateViewport: false,
	models: [],
	stores: [],
	controllers: [],
	
	launch: function() {
		// application wide functions
		App.functions = Ext.create('App.util.Functions');
	}
});