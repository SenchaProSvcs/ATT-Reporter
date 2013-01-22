Ext.define('AttApi.store.AllApiTests', {

    extend  : 'Ext.data.Store',
    model   : 'AttApi.model.AllApiResponseTime',

    // we define the proxy here on the store instead of the model
    // since we create a separate instance of the store for each
    // history tab

    proxy   : {
        type    : 'ajax',
        api     : {
            read    : AttApi.config.attApiBasePath + '/history_data_paged'
        },
        reader  : {
            type    : 'array',
            root    : 'data'
        }
    }

});
