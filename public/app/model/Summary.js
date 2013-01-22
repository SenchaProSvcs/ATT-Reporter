/*
 * Having to use a custom Model for the Summary form since IE can NOT handle the datetime string
 * sent from the server. So we use a convert fn that uses the Ext.Date.format method seems to fix the issue for IE
 */
Ext.define('AttApi.model.Summary', {
    
    extend  : 'Ext.data.Model',
    
    fields  : [
        'testUser', 
        'publicServer',
        'testsAreRunning',
        'shortCode',
        'testPassword',
        { 
            name        : 'testsStartTime', 
            type        : 'date', 
            //dateFormat  : 'M j, g:i a T',
            convert     : function(v) {
                
                // dateFormat doesn't appear to work in IE so using a convert fn instead
                // can NOT use dt = new Date(v) in IE since it can not parse the datetime string
                
                // example format sent from the server = '2011-09-10T16:00:15+00:00'
                var dt = Ext.Date.parse(v,'Y-m-dTH:i:sP');
                return Ext.Date.format(dt, 'M j, g:i a T');
            }
        },
        
        'tel',
        'testsStartTimeEpoch',
        'localServer',
        'clientSecret',
        'clientID',
        'baseURL'
    ]
    
});