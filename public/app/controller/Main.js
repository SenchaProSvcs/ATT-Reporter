Ext.define('Reporter.controller.Main', {
    extend: 'Ext.app.Controller',
    
    init: function() {
        var me = this;
        
        me.control({
            '#last-results-grid': {
                render: me.onResultsGridRender,
                selectionchange: me.onResultsGridSelectionChange
            }
        });
    },
    
    onResultsGridRender: function(grid) {
        grid.getStore().load(function(results) {
            var firstResult = results[0];

            if (firstResult) {
                var executionDate = firstResult.raw.test_execution_created_at;
                
                if (executionDate) {
                    grid.down('#api-status-header').update({
                        lastUpdate: new Date(executionDate)
                    });
                }
            }
        });
    },
    
    onResultsGridSelectionChange: function(grid, selected) {
        var testResult = selected[0],
            testStore = Ext.getStore('TestResults');
        
        if (!testResult) {
            return;
        }
        
        testStore.getProxy().extraParams = {
            method_id: testResult.get('method_id')
        };
        testStore.load();
    }
});