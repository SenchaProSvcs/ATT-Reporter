Ext.define('Reporter.store.TestResults',{
    extend: 'Ext.data.Store',
    requires: [
        'Ext.data.reader.Json'
    ],
    
    model: 'Reporter.model.TestResult',
    buffered: true,
    pageSize: 100,
    remoteSort: true,
    sorters: {
        property: 'created_date',
        direction: 'ASC'
    },
    proxy: {
        type: 'ajax',
        url: '/api_method_details',
        simpleSortMode: true,
        reader: {
            type: 'json'
        }
    }
});