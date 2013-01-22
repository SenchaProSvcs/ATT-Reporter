Ext.define('AttApi.controller.Oauth', {
    
    extend  : 'AttApi.controller.Base',
    stores  : ['OauthApiTests','ChartChoices'],
    models  : ['OauthApiResponseTime'],
    views   : [
        'oauth.BarStackedChart',
        'oauth.BarUnstackedChart',
        'oauth.ChartPanel',
        'oauth.ColumnStackedChart',
        'oauth.ColumnUnstackedChart',
        'oauth.LineChart'
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
            
            'oauth-chartpanel': {
                afterrender: me.onChartPanelAfterRender,
                activate: me.onChartPanelActivate
            },
            
            'oauth-chartpanel combobox[itemId="cbDataPoints"]' : {
                select: me.onDataPointsSelect
            },
            
            'oauth-chartpanel combobox[itemId="cbChartChooser"]' : {
                select: me.onChartChooserSelect
            }
        
        });
    },

    // make sure we have the latest data
    onChartPanelActivate: function(chartPanel) {
        chartPanel.down('chart').store.load();
    },
    
    onChartPanelAfterRender: function(chartPanel) {
        var me     = this,
            cfg    = AttApi.config,
            store  = Ext.create('AttApi.store.OauthApiTests', {
                pageSize : cfg.defaultPageSize
            });
        
        // capture a reference to our chartPanel
        store.chartPanel = chartPanel;
        
        // add our base params 
        store.getProxy().extraParams = {
            testName : chartPanel.testId
        };
        
        // now add our store listeners for the OauthApiTests store
        store.on('load', me.moveChartToLastPage, me, {single:true});
        store.on('load', me.onLoadOauthApiTests, me);
        store.on('beforeload', me.onBeforeLoadOauthApiTests, me);
        
        // now add the new chart
        chartPanel.add({
            itemId  : 'oauthChartCt',
            layout  : 'fit',
            border  : false,
            items   : [{
                xtype   : 'oauth-ColumnStackedChart',
                store   : store
            }],
            dockedItems : [{
                dock  : 'bottom',
                xtype : 'pagingtoolbar',
                store : store
            }]
        });
        
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

    onBeforeLoadOauthApiTests : function(store) {
        var viewer   = this.getViewer(),
            oauthTab = viewer.down('#oauthChartPanel');
    
        oauthTab.getEl().mask('Loading chart...');
        
    },
    
    onLoadOauthApiTests : function(store) {
        var viewer   = this.getViewer(),
            oauthTab = viewer.down('#oauthChartPanel');
            
        oauthTab.getEl().unmask();
    },
    
    onChartChooserSelect: function(combo, recs) {
        var pnl     = combo.up('panel'),
            chartCt = pnl.down('#oauthChartCt'),
            chart   = pnl.down('chart'),
            store   = chart.store,
            rec     = recs[0];
    
        chartCt.remove(chart);
        chartCt.add({
            itemId  : 'chart',
            xtype   : 'oauth-' + rec.get('id'),
            store   : store
        });
        
        pnl.doLayout();
    }
    
});