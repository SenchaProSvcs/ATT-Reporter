Ext.define('Reporter.controller.Main', {
    extend: 'Ext.app.Controller',
    
    init: function() {
        var me = this;
        
        me.control({
            '#last-results-grid': {
                render: me.onResultsGridRender,
                selectionchange: me.onResultsGridSelectionChange
            },
            
            '#results-details-grid': {
                selectionchange: me.onResultsDetailsSelectionChange
            },
            
            '#refresh-btn': {
                click: me.onRefreshBtnClick
            }
        });
    },
    
    onResultsGridRender: function(grid) {
        grid.getStore().load(function(results) {
            var firstResult = results[0];

            if (firstResult) {
                var executionDate = firstResult.raw.test_execution_created_date;
                
                if (executionDate) {
                    grid.down('#api-status-header').update({
                        lastUpdate: new Date(executionDate)
                    });
                }
            }
        });
    },
    
    onResultsGridSelectionChange: function(selModel, selected) {
        var testResult = selected[0],
            testStore = Ext.getStore('TestResults');
        
        if (!testResult) {
            return;
        }
        
        testStore.getProxy().extraParams = {
            method_id: testResult.get('method_id')
        };
        testStore.load();
    },
    
    onResultsDetailsSelectionChange: function(selModel, selected) {
        var testResult = selected[0],
            logCt = selModel.view.ownerCt.nextSibling('#log-container');
        
        logCt.setValue(testResult ? testResult.get('log') : '');
    },
    
    onRefreshBtnClick: function(btn) {
        var testResults = Ext.getStore('TestResults');
        
        Ext.getStore('LastTestResults').reload();
        
        if (testResults.getProxy().extraParams.method_id) {
            testResults.reload();
        }
    }
});