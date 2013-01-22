Ext.define('AttApi.view.oauth.AbstractChart', {
    
    extend  : 'Ext.chart.Chart',
    alias   : 'widget.oauth-AbstractChart',
    shadow  : false, // since stacked columns have a bug and show the shadow below the x-axis
    
    legend  : {
        position: 'bottom'
    },
    
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
    },

    dateRenderer: function(txt) {
        // we have to make sure we have a value since for some reason the label renderer function
        // gets called at least twice and when we have only one data point that second call passes
        // undefined to the function.  So if you ever think you'll have data with just one point
        // make sure you check what's passed to you
        if (txt) {
            return Ext.Date.format(new Date(Number(txt)*1000), "M j, g:i a");
        } else {
            return "";
        }
    }

});