Ext.define('AttApi.view.oauth.ChartPanel', {

    extend      : 'Ext.panel.Panel',
    alias       : 'widget.oauth-chartpanel',
    itemId      : 'oauthChartPanel',
    collapsible : true,
    title       : 'Response times over time',
    layout      : 'fit',
    flex        : 1,

    
    initComponent: function(){
        var me = this;
        Ext.apply(me,{
            items  : [],
            tbar   : me.buildTbarItems()
        });
        this.callParent(arguments);
    },

    buildTbarItems : function() {
        var cfg = AttApi.config;
        
        return [
            {
                xtype           : 'combo',
                itemId          : 'cbChartChooser',
                fieldLabel      : 'Choose Chart',
                labelAlign      : 'right',
                valueField      : 'id',
                displayField    : 'name',
                store           : Ext.create('AttApi.store.ChartChoices'),
                value           : cfg.defaultChartId,
                forceSelection  : true,
                queryMode       : 'local'
            },
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