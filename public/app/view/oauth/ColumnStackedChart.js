Ext.define('AttApi.view.oauth.ColumnStackedChart', {
    
    extend  : 'AttApi.view.oauth.AbstractChart',
    alias   : 'widget.oauth-ColumnStackedChart',
    
    buildAxes: function() {
        return [
            {
                title       : 'Time of Test Run (' + Ext.Date.format(new Date(), 'T') + ')',
                position    : 'bottom',
                type        : 'Category',
                fields      : ['start_time'],
                label       : {
                    renderer: this.dateRenderer,
                    rotate  : {
                        degrees: 70
                    }
                }    
            },
            {
                title       : 'Response Time (s)',
                position    : 'left',
                type        : 'Numeric',
                fields      : ['login', 'auth_screen', 'auth_code', 'access_token'],
                grid        : true,
                minimum     : 0
            }
        ];
    },

    buildSeries: function(){
        return [
            {
                type    : 'column',
                axis    : 'left',
                gutter  : 80,
                xField  : 'start_time',
                yField  : ['login', 'auth_screen', 'auth_code', 'access_token'],
                stacked : true
            }
        ];
    }
});