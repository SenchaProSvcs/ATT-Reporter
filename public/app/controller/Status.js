Ext.define('AttApi.controller.Status', {
    
    extend  : 'AttApi.controller.Base',
    stores  : ['Tests'],
    models  : ['Test','Summary'],
    views   : ['status.Grid', 'summary.SummaryPanel'],

    refs    : [
        {
            ref: 'viewer',
            selector: '[itemId=viewer]'
        },
        {
            ref: 'lastRun',
            selector: '[itemId=lastrun]'
        },
        {
            ref: 'statusGrid',
            selector: 'status-grid'
        },
        {
            ref: 'summaryPanel',
            selector: 'summary-panel'
        },
        {
            ref: 'oauthChartPanel',
            selector: 'oauth-chartpanel'
        }
    ],


    init: function() {
        var me = this;
        
        me.control({
            'status-grid': {
                itemclick: me.loadTestChart
            },
            
            '[region="west"] tool[type="refresh"]': {
                click: me.refreshData
            },
            
            'summary-panel button[itemId="refresh"]': {
                click: me.refreshData
            },
            
            'summary-panel displayfield[name="testsStartTime"]': {
                change: me.updateLastRun
            }
            
        });
    },

    onLaunch: function() {
    
    },
    
    updateLastRun : function(fld, newVal, oldVal){
        this.getLastRun().update('Last Run: ' + newVal);
    },
    

    /**
     * Loads the chart for a given Test into a new tab
     */
    loadTestChart: function(grid, rec) {
        var me = this,
            viewer = me.getViewer(),
            testId,
            tab;
    
        testId = rec.get('test');
        
        // do we already have a tab for this chart?
        //tab = viewer.down('[testId=' + testId + ']');
        tab = Ext.ComponentQuery.query('[testId=' + testId + ']')[0];
        if (!tab) {
            tab = viewer.add({
                xtype       : 'history-chartpanel',
                title       : testId,
                testId      : testId,
                closable    : true
            });
        }
        
        tab.show();
        return tab;
    },
    
    
    refreshData : function(pnl, e){
        var me = this,
            grid = me.getStatusGrid(),
            store = grid.getStore(),
            tabPanel = me.getViewer(),
            activeTab = tabPanel.activeTab,
            activeChart = activeTab.down('chart'),
            summaryTab = me.getSummaryPanel();
        
        // reload the store for the status grid
        store.load();
        
        // reload the summary page's data
        summaryTab.loadSummaryData();
        
        // if there is an activeTab with a chart, reload it
        if (activeChart && activeChart.refreshChart) {
            activeChart.refreshChart();
        }
    }
    

});