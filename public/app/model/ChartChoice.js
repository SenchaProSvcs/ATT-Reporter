Ext.define('AttApi.model.ChartChoice', {
    
    extend  : 'Ext.data.Model',  
     
    proxy: {
        type: 'memory'
    },
     
    fields  : [
        {name: 'id', type: 'string'}, 
        {name: 'name',  type: 'string'}
    ]

});