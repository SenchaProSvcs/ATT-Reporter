Ext.define('Reporter.controller.Main', {
    extend: 'Ext.app.Controller',
    
    refs: [{
        ref: 'chart',
        selector: 'chart'
    }],
    
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
        testStore.loadPage(1);
    },
    
    onResultsDetailsSelectionChange: function(selModel, selected) {
        var testResult = selected[0],
            logCt = selModel.view.ownerCt.nextSibling('#log-container');
        
        logCt.setValue(testResult ? testResult.get('log') : '');
        this.highlightResult(testResult);
    },
    
    onRefreshBtnClick: function(btn) {
        var testResults = Ext.getStore('TestResults');
        
        Ext.getStore('LastTestResults').reload();
        
        if (testResults.getProxy().extraParams.method_id) {
            testResults.loadPage(1);
        }
    },
    
    highlightResult: function(testResult) {

        if (!testResult) {
            return;
        }
        
        var id = testResult.getId(),
            series = this.getChart().series.get(0),
            i, items, l;

        series.highlight = true;
        series.unHighlightItem();
        series.cleanHighlights();
        for (i = 0, items = series.items, l = items.length; i < l; i++) {
            if (id == items[i].storeItem.getId()) {
                series.highlightItem(items[i]);
                break;
            }
        }
        series.highlight = false;
    }
});