Ext.define('AttApi.controller.History', {

    extend  : 'AttApi.controller.Base',
    stores  : ['AllApiTests', 'LogEntries'],
    models  : ['AllApiResponseTime', 'LogEntry'],
    views   : [
        'history.ChartPanel',
        'history.LineChart',
        'history.Grid'
    ],

    refs    : [
        {
            ref: 'viewer',
            selector: '[itemId=viewer]'
        }
    ],

    init: function() {
        var me = this;

        me.control({

            'history-grid': {
                itemclick: me.loadHistoryDetail
            },

            'history-chartpanel': {
                afterrender: me.onChartPanelAfterRender,
                activate: me.onChartPanelActivate
            },

            'history-chartpanel combobox[itemId="cbDataPoints"]' : {
                select: me.onDataPointsSelect
            },

            'history-grid tool[type="save"]': {
                click: me.exportGrid
            }

        });

    },

    onLaunch: function(){

    },

    onChartPanelActivate: function(chartPanel) {
        chartPanel.down('chart').store.load();
    },

    onChartPanelAfterRender: function(chartPanel){
        var me      = this,
            cfg     = AttApi.config,
            chartCt = chartPanel.down('#chartCt'),
            gridCt  = chartPanel.down('#gridCt'),
            store   = Ext.create('AttApi.store.AllApiTests', {
                pageSize : cfg.defaultPageSize
            }),
            gridStore;

        // capture a reference to our chartPanel
        store.chartPanel = chartPanel;

        // add our base params
        store.getProxy().extraParams = {
            testName : chartPanel.testId
        };

        // now add our store listeners for the AllApiTests store
        store.on('load', me.moveChartToLastPage, me, {single:true});
        store.on('load', me.onLoadAllApiTests, me);
        store.on('beforeload', me.onBeforeLoadAllApiTests, me);

        // now add the chart
        chartCt.add({
            layout : 'fit',
            border : false,
            items  : [{
                xtype : 'history-linechart',
                store : store
            }],
            /*dockedItems : [{
                dock  : 'bottom',
                xtype : 'pagingtoolbar',
                store : store
            }],*/
            bbar : {
                xtype : 'pagingtoolbar',
                store : store
            }
        });

        // now add the grid
        gridStore = me.createGridStore();
        gridStore.chartPanel = chartPanel;
        gridCt.add({
            itemId  : 'grid',
            xtype   : 'history-grid',
            layout  : 'fit',
            store   : gridStore
        });

        // since we dynamically added components we need a doLayout call
        chartPanel.doLayout();

        // for the initial load set the limit to 0
        // so we can just get the total for the paging toolbar
        // we then have a load listener on the store to then
        // take us to the last page
        store.load({
            params : {
                start : 0,
                limit : 0
            }
        });

    },

    onBeforeLoadAllApiTests : function(store) {
        store.chartPanel.getEl().mask('Loading chart...');
    },

    onLoadAllApiTests: function(store) {
        var me   = this,
            chartPanel = store.chartPanel,
            grid = chartPanel.down('#grid'),
            detailsCt = chartPanel.down('#detailsCt'),
            records;

        //remove current details
        detailsCt.removeAll();

        // copy the records from the chart store
        records = me.cloneStoreRecords(store);

        // load these records into the grid's store
        grid.getStore().loadRecords(records);

        chartPanel.getEl().unmask();
    },

    onLoadLogs: function(store){
        var chartPanel = store.chartPanel,
            detailsCt = chartPanel.down('#detailsCt'),
            recIdx  = store.find('test', chartPanel.testId),
            rec     = store.getAt(recIdx),
            errors  = rec ? rec.get('errors') : ['Test did not collect any data'];

        // remove current details
        detailsCt.removeAll();

        // now add the new details
        for (var i=0, len=errors.length; i<len; i++) {
            detailsCt.add({
                xtype   : 'container',
                html    : '<pre>' + Ext.util.Format.nl2br(Ext.util.Format.htmlEncode(errors[i])) + '</pre>',
                padding : 5
            });
        }

        detailsCt.getEl().unmask();
    },

    loadHistoryDetail: function(gridview, rec) {
        var me = this,
            grid = gridview.up('gridpanel'),
            gridStore = gridview.getStore(),
            chartPanel = grid.up('panel'),
            detailsCt = chartPanel.down('#detailsCt'),
            startTime,
            logStore;


        logStore = new AttApi.store.LogEntries({chartPanel: gridStore.chartPanel});
        startTime = rec.get('start_time');

        detailsCt.getEl().mask("Loading details...");

        // define a load listener
        logStore.on('load', me.onLoadLogs, me);

        // now load the data
        logStore.load({
            params : {
                ts : startTime
            }
        });
    },

    createGridStore: function(store) {
        var gridStore;

        gridStore = new Ext.data.Store({
            model : 'AttApi.model.AllApiResponseTime',
            proxy : {
                type : 'memory'
            },
            sorters : [{
                property : 'start_time',
                direction: 'DESC'
            }]
        });

        return gridStore;
    },

    cloneStoreRecords: function(store) {
        var records = [];
        for (var i=0, len=store.data.length; i<len; i++){
            records.push(store.getAt(i).copy());
        }
        return records;
    },

    exportGrid : function(tool, e){
        var chartPanel = tool.up('history-chartpanel');
        location.href = 'history_data_csv?testName=' + chartPanel.testId;
    }

});