Ext.define('AttApi.model.AllApiResponseTime', {
    
    extend  : 'Ext.data.Model',
    
    // proxy defined on the store, otherwise the same proxy
    // is used for this model for each instance of a history tab
    // and we don't want that
    
    fields  : [
        'start_time', 
        'duration',
        'msg'
    ]
    
});