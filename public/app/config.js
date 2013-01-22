Ext.define('AttApi.config', {
    singleton : true,
    
    /**
     * The basepath to the ruby app responding
     * to the poller api calls
     * Usually this is just '' but if you
     * have configured a ProxyPass then
     * you can set this to that path
     */
    
    //attApiBasePath     : '/att/pollerapi',
    attApiBasePath      : '.',
    
    
    startDataSliceLast  : true,  
    defaultChartId      : 'ColumnStackedChart',
    defaultPageSize     : 20
        
});