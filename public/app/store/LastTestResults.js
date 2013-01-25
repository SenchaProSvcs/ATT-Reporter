Ext.define('Reporter.store.LastTestResults',{
    extend: 'Ext.data.Store',
    requires: [
        'Ext.data.reader.Json'
    ],
    
    model: 'Reporter.model.TestResult',
    groupers: [{
        property: 'api_name'
    }],
    proxy: {
        type: 'ajax',
        url: '/last_test_results',
        reader: {
            type: 'json'
        }
    }
});