Ext.define('AttApi.view.oauth.LineChart', {
    
    extend  : 'AttApi.view.oauth.AbstractChart',
    alias   : 'widget.oauth-LineChart',
    
    buildAxes: function() {
        return [
            {
                title       : 'Time of Test Run (' + Ext.Date.format(new Date(), 'T') + ')',
                position    : 'bottom',
                type        : 'Category',
                fields      : ['start_time'],
                label       : {
                    renderer: function(txt) {
                        return Ext.Date.format(new Date(Number(txt)*1000), "M j, g:i a");
                    },
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
        var me = this;
        
        return [
            {
                type        : 'line',
                title       : '1. Load login screen',
                axis        : 'left',
                xField      : 'start_time',
                yField      : 'login',
                highlight   : { radius: 1.5, 'stroke-width': 0 },
                tips        : me.tips('login')
            },
            {
                type        : 'line',
                axis        : 'left',
                title       : '2. Load auth screen',
                xField      : 'start_time',
                yField      : 'auth_screen',
                highlight   : { radius: 1.5, 'stroke-width': 0 },
                tips        : me.tips('auth_screen')
            },
            {
                type        : 'line',
                axis        : 'left',
                title       : '3. Obtain auth code',
                xField      : 'start_time',
                yField      : 'auth_code',
                highlight   : { radius: 1.5, 'stroke-width': 0 },
                tips        : me.tips('auth_code')
            },
            {
                type        : 'line',
                axis        : 'left',
                title       : '4. Obtain access token',
                xField      : 'start_time',
                yField      : 'access_token',
                highlight   : { radius: 1.5, 'stroke-width': 0 },
                tips        : me.tips('access_token')
            }
          ];
    },
    
    tips: function(field) {
        return {
            renderer: function(storeItem, item) {
                this.update(Ext.util.Format.number(storeItem.get(field), '0.000') + " s");
            }
        };
    }
          
});