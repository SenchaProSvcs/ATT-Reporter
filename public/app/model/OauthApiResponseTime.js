Ext.define('AttApi.model.OauthApiResponseTime', {
    
    extend  : 'Ext.data.Model',
    
    proxy   : {
        type    : 'ajax',
        api     : {
            read    : AttApi.config.attApiBasePath + '/history_oauth_data_paged'
        },
        reader  : {
            type    : 'array',
            root    : 'data'
        }
    },
    
    fields  : [
        {
            name    : 'start_time',
            mapping : 0, 
            type    : 'float'
        },                      
        {
            name    : 'login',
            mapping : 1
        },
        {
            name    : 'login_msg',
            mapping : 2 
        },
        {
            name    : 'auth_screen',
            mapping : 3
        },
        {
            name    : 'auth_screen_msg',
            mapping : 4
        },
        {
            name    : 'auth_code',
            mapping : 5
        },
        {
            name    : 'auth_code_msg',
            mapping : 6
        },
        {
            name    : 'access_token',
            mapping : 7
        },
        {
            name    : 'access_token_msg',
            mapping : 8
        }
    ]
});