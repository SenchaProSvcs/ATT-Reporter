Ext.define('AttApi.store.OauthApiTests', {

    extend : 'Ext.data.Store',
    model  : 'AttApi.model.OauthApiResponseTime',
    
    sorters : [
        {
            property    : 'start_date',
            direction   : 'DESC'
        }
    ],
    sortOnLoad  : true
    
});