Ext.define('AttApi.view.Viewport', {
    extend: 'Ext.container.Viewport',

    requires: [
        'AttApi.view.status.Grid',
        'AttApi.view.summary.SummaryPanel',
        'Ext.layout.container.Border'
    ],

    layout  : 'border',
    padding : 5,

    items: [
        /*{
            region      : 'north',
            height      : 35,
            padding     : '0 0 5 0',
            bodyStyle   : 'padding: 5px;',
            html        : "Sencha's AT&T API Status"
              
        },*/
        {
            region      : 'center',
            itemId      : 'viewer',
            //title       : "Sencha's AT&T API Status",
            xtype       : 'tabpanel',
            plain       : true,
            activeTab   : 0,
            items       : [
                {
                    title   : 'Summary',
                    xtype   : 'summary-panel'
                },
                {
                    title   : 'Oauth Latency Chart',
                    xtype   : 'oauth-chartpanel'
                }
            ]
        },
        {
            region      : 'west',
            split       : true,
            frame       : true,
            //title     : "Complete API Tests",
            title       : "Sencha's AT&T API Status",
            width       : 300,
            collapsible : true,
            border      : false,
            layout      : {
                type    : 'vbox',
                align   : 'stretch'
            },
            items       : [
                {
                    xtype   : 'status-grid',
                    //border  : false,
                    flex    : 1
                },
                {
                    itemId   : 'lastrun',
                    html     : '',
                    frame    : true,
                    bodyStyle : 'padding : 5px;',
                    height   : 30
                }
            ],
            tools:[
                {
                    type    : 'refresh',
                    qtip    : 'Refresh'
                }
            ]
        }
    ]
});