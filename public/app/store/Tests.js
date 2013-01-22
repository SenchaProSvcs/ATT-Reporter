Ext.define('AttApi.store.Tests', {
    extend: 'Ext.data.Store',
    model: 'AttApi.model.Test',
    autoLoad: true,
    proxy: {
        type: 'ajax',
        url: AttApi.config.attApiBasePath + '/status_data',
        reader: {
            type: 'json',
            root: 'tests'
        }
    }
});
