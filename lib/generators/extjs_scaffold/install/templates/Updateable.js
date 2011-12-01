/**
 * @author Mark H Winkler
 * @mixin App.ux.data.Updatable
 * Required use: Model class
 * 
 * Adds updateModel function to Model class, which updates the model with field data
 *  from the passed record
 *
 * Performs a commit so that the changes are not dirty - so Model should be saved to remote
 *  prior to call (if necessary)
 *
 * params:
 * record (model record) - required - record with changed field data
 *
 */
Ext.define('<%= app_name %>.ux.data.Updateable', {
	updateModel: function(record) {
		var me = this;
		var fields = this.fields

		// update all fields except id, but only if data is changed
		Ext.Array.each(fields.items, function(field) {
			var name = field.name;
			if (name != 'id' && record.get(name) != me.get(name)) {
				me.set(name, record.get(name));
			}
		});
		// clear dirty record - assumes already saved to remote (if necessary)
		me.commit();	
	}
});