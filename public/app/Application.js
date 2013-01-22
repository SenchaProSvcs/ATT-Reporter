Ext.application({
    name: 'AttApi',    

    // Ext.chart.* is needed to avoid this exception: uncaught exception: No theme found named "Base"
    // more info here: http://www.sencha.com/forum/showthread.php?143864-Using-chart-themes-with-ext-debug.js
    requires : [
        'AttApi.config',
        'Ext.chart.*'
    ],
    
    // Define all the controllers that should initialize at boot up of your application
    controllers: [
        'Status',
        'History',
        'Oauth'
    ],


    autoCreateViewport: true,

    launch: function() {
        //console.log('application launch');
    }

});