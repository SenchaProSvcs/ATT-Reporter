Ext.define('Reporter.store.LastTestResults',{
    extend: 'Ext.data.Store',
    requires: [
        'Ext.data.reader.Json'
    ],
    
    model: 'Reporter.model.TestResult',
    groupers: [{
        property: 'api_name'
    }],
    remoteSort: false,
    sorters: {
        property: 'created_date',
        direction: 'ASC'
    },
    proxy: {
        type: 'ajax',
        url: '/last_test_results',
        simpleSortMode: true,
        reader: {
            type: 'json'
        }
    }
});