Ext.define('Reporter.model.TestResult', {
    extend: 'Ext.data.Model',
    fields: [{
        name: 'id',
        type: 'int'
    }, {
        name: 'method_id',
        type: 'string'
    }, {
        name: 'name',
        type: 'string'
    }, {
        name: 'api_name',
        type: 'string'
    }, {
        name: 'created_date',
        type: 'date'
    }, {
        name: 'finished_date',
        type: 'date'
    }, {
        name: 'duration',
        type: 'float'
    }, {
        name: 'result',
        type: 'int'
    }, {
        name: 'log',
        type: 'string'
    }],
    statics: {
      PASSED: 1,
      WARNING: 2,
      ERROR: 3
    }
});