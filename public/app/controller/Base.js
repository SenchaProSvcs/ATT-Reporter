Ext.define('AttApi.controller.Base', {
        
    extend  : 'Ext.app.Controller',
    stores  : [],
    models  : [],
    views   : [],

    refs: [
        {
            ref: 'viewer',
            selector: '[itemId=viewer]'
        }
    ],

    init: function(){},

    onLaunch: function(){},

    onDataPointsSelect: function(combo, recs) {
        var me = this,
            chartPanel = combo.up('panel'),
            pagingTbar = chartPanel.down('pagingtoolbar'),
            chart = chartPanel.down('chart'),
            store = chart.store,
            newPageSize = recs[0].get('field1');
        
        store.pageSize = newPageSize;
        pagingTbar.currentPage = 1;
        
        store.on('load', me.moveChartToLastPage, me, {single:true});
        store.load({
            params : {
                start : 0,
                limit : newPageSize
            }
        });

    },
    
    moveChartToLastPage: function(store){
        var pagingTbar = store.chartPanel.down('pagingtoolbar');
        pagingTbar.moveLast();
    }
    
                
});