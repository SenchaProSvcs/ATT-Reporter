Ext.define('AttApi.view.oauth.BarUnstackedChart', {

    extend  : 'AttApi.view.oauth.AbstractChart',
    alias   : 'widget.oauth-BarUnstackedChart',
    
    buildAxes: function() {
        return [
            {
                title       : 'Time of Test Run (' + Ext.Date.format(new Date(), 'T') + ')',
                position    : 'left',
                type        : 'Category',
                fields      : ['start_time'],
                label       : {
                    renderer: function(txt) {
                        return Ext.Date.format(new Date(Number(txt)*1000), "M j, g:i a");
                    }
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
                yField  : ['login', 'auth_screen', 'auth_code', 'access_token']
            }
        ];
    }
});