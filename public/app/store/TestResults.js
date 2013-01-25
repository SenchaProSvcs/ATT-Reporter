Ext.define('Reporter.store.TestResults',{
    extend: 'Ext.data.Store',
    requires: [
        'Ext.data.reader.Json'
    ],
    
    model: 'Reporter.model.TestResult',
    proxy: {
        type: 'ajax',
        url: '/api_method_details',
        reader: {
            type: 'json'
        }
    }
});