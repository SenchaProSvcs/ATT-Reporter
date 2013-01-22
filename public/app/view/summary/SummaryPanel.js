Ext.define('AttApi.view.summary.SummaryPanel', {

    extend  : 'Ext.form.Panel',
    
    requires: ['Ext.Date'],
    
    alias   : 'widget.summary-panel',
    border  : false,
    
    
    itemId       : 'pnlSummary',
    bodyStyle    : 'padding: 10',
    border       : false,
    
    tbar : [
        {
            xtype   : 'button',
            itemId  : 'refresh',
            text    : 'Refresh'
        }
    ],
    
    initComponent: function(){
        var me = this;
        
        me.defaultType = 'displayfield';
        me.defaults = {anchor: '95%'};
        
        me.items = me.buildItems();
        
        me.callParent();
    },
    
    afterRender: function(){
        var me = this,
            frm = me.getForm();
        
        // specifying the reader on the formpanel didn't work (I guess it didn't get
        // passed down to the form property since the readRecords method looks for
        // any custom readers by checking this.form.reader
        frm.reader = Ext.create('Ext.data.reader.Json', {
            model : 'AttApi.model.Summary',
            root : 'data',
            record: ''
        });
        
        me.loadSummaryData();
        
        me.callParent(arguments);
    },
          
    loadSummaryData: function() {
        this.load({
            method  : 'GET',
            url     : AttApi.config.attApiBasePath + '/status_summary',
            waitMsg : 'Loading...'
        });
    },
    
    buildItems: function(){
        
        return [
            {
                xtype: 'container',
                html: '<h1 id="sencha-logo-header">Sencha&rsquo;s AT&T API Status</h1>'
            },
           {
               fieldLabel : 'Last Run',
               name       : 'testsStartTime',
               xtype      : 'displayfield'
           },
           {
               fieldLabel : 'Endpoint',
               name       : 'baseURL'
           },
           {
               fieldLabel : 'Username',
               name       : 'testUser'
           },
           {
               fieldLabel : 'Password',
               name       : 'testPassword'
           },
           {
               fieldLabel : 'Client ID',
               name       : 'clientID'
           },
           {
               fieldLabel : 'Client Secret',
               name       : 'clientSecret'
           },
           {
               fieldLabel : 'Cell Phone',
               name       : 'tel'
           }
        ];
    }
    
});