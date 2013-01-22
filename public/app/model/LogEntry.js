Ext.define('AttApi.model.LogEntry', {
    
    extend  : 'Ext.data.Model',
    
    proxy   : {
        type    : 'ajax',
        api     : {
            read    : AttApi.config.attApiBasePath + '/log_data'
        },
        reader  : {
            type    : 'json',
            root    : 'data'
        }
    },
    
    fields  : [
        'test', 
        'errors'
    ]
    
});