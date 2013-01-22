Ext.define('AttApi.view.history.AbstractChart', {
    
    extend          : 'Ext.chart.Chart',
    alias           : 'widget.history-abstractchart',
    shadow          : false, // since stacked columns have a bug and show the shadow below the x-axis
    insetPadding    : 20,
       
    initComponent: function(){
        var me = this;
           
        me.axes = me.buildAxes();
        me.series = me.buildSeries();
           
        me.callParent();
           
    },
       
    buildAxes: function() {},

    buildSeries: function() {},
    
    refreshChart: function() {
        this.store.load();
    }

});
    
