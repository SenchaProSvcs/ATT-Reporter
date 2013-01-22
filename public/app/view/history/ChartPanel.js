Ext.define('AttApi.view.history.ChartPanel', {

    extend      : 'Ext.panel.Panel',
    alias       : 'widget.history-chartpanel',
    collapsible : true,
    title       : 'Response times over time',
    layout      : 'border',
    
    // Ext bug?  if dockedItems is used then only the last tab loaded has the dockedItem
    // looks like the auto generated id is the same so perhaps the bug is there?
    /*
    dockedItems : [{
        xtype   : 'toolbar',
        dock    : 'top',
        items   : me.buildTbarItems()
    }],
    */
    initComponent: function(){
        var me = this;
        Ext.apply(me,{
            items  : me.buildItems(),
            tbar   : me.buildTbarItems()
        });
        this.callParent(arguments);
    },

    buildItems : function() {
        // overnest since we can't dynamically add/remove regions
        return [
            { 
                region      : 'center',
                itemId      : 'chartCt',
                layout      : 'fit',
                flex        : .7  
            },
            {
                region      : 'south',
                split       : true,
                header      : false,
                border      : false,
                //title       : 'Raw Data',
                flex        : .3,
                collapsible : true,
                layout      : {
                    type    : 'hbox',
                    align   : 'stretch'
                },
                items       : [
                    {
                        xtype   : 'container',
                        itemId  : 'gridCt',
                        layout  : 'fit',
                        flex    : .3
                    },
                    {
                        //title   : 'Details',
                        itemId        : 'detailsCt',
                        autoScroll    : true,
                        flex          : .7,
                        items         : [{
                            html      : 'Click on row to see more details.',
                            padding   : 5,
                            border    : false
                        }]
                    }
                ]
            }
        ];
    },

    buildTbarItems : function() {
        var cfg = AttApi.config;
        
        return [
            {
                xtype           : 'combo',
                itemId          : 'cbDataPoints',
                fieldLabel      : '# of data points',
                labelAlign      : 'right',
                width           : 150,
                store           : [10,20,30,40,50,75,100,150,200,300,400,500],
                value           : cfg.defaultPageSize,
                forceSelection  : true,
                queryMode       : 'local'
            }
        ];
    }
});