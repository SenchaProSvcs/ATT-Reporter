Ext.define('AttApi.view.oauth.BarStackedChart', {

    extend  : 'AttApi.view.oauth.AbstractChart',
    alias   : 'widget.oauth-BarStackedChart',
    
    buildAxes: function() {
        return [
            {
                title       : 'Time of Test Run (' + Ext.Date.format(new Date(), 'T') + ')',
                position    : 'left',
                type        : 'Category',
                fields      : ['start_time'],
                label       : {
                    renderer: this.dateRenderer
                }    
            },
            {
                title       : 'Response Time (s)',
                position    : 'bottom',
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
                type    : 'bar',
                axis    : 'bottom',
                gutter  : 80,
                xField  : 'start_time',
                yField  : ['login', 'auth_screen', 'auth_code', 'access_token'],
                stacked : true
                  
            }
        ];
    }
});