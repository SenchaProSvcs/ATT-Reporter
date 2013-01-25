Ext.define('Reporter.model.TestExecution', {
    extend: 'Ext.data.Model',
    requires: [
        'Ext.data.reader.Json',
        'Ext.data.writer.Json'
    ],
    fields: [{
        name: 'id',
        type: 'int'
    }, {
        name: 'created_date',
        type: 'date'
    }, {
        name: 'finished_date',
        type: 'date'
    }, {
        name: 'status',
        type: 'auto'
    }],
    hasMany: 'TestResults',
    proxy: {
        type: 'rest',
        url: '/test_results'
    }
});