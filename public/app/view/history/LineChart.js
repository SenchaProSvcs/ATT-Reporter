Ext.define('AttApi.view.history.LineChart', {
   
    extend  : 'AttApi.view.history.AbstractChart',
    alias   : 'widget.history-linechart',
    
    initComponent: function(){
        var me = this;
        Ext.apply(me, {
            //store   : "TestItems" 
        });
        me.callParent();
    },
    
   buildAxes: function() {
       return [
           {
               title        : false,
               type         : 'Numeric',
               minimum      : 0,
               //maximum      : 30,
               position     : 'left',
               fields       : ['duration'],
               grid         : true,
               label        : {
                   renderer: Ext.util.Format.numberRenderer('0,0'),
                   font : '10px Arial'
               }
           }, 
           {
               title        : 'Time of Test Run (' + Ext.Date.format(new Date(), 'T') + ')',
               type         : 'Category',
               position     : 'bottom',
               fields       : ['start_time'],
               label        : {
                   font     : '10px Arial',
                   renderer : function(txt) {
                       // we have to make sure we have a value since for some reason the label renderer function
                       // gets called at least twice and when we have only one data point that second call passes
                       // undefined to the function.  So if you ever think you'll have data with just one point
                       // make sure you check what's passed to you
                       if (txt) {
                           return Ext.Date.format(new Date(Number(txt)*1000), "M j, g:i a");
                       } else {
                           return "";
                       }
                       
                   },
                   rotate   : {
                       degrees: 70
                   }
               }
           }
       ];
   },

   buildSeries: function(){
       return [
           {
               type     : 'line',
               axis     : 'left',
               xField   : 'start_time',
               yField   : 'duration',
               listeners: {
                   itemmouseup: function(item) {
                       //Ext.example.msg('Item Selected', item.value[1] + ' visits on ' + Ext.Date.monthNames[item.value[0]]);
                   }  
               },  
               tips: {
                   renderer: function(storeItem, item) {
                       var date = storeItem.get('start_time'),
                           dateFormatted = Ext.Date.format(new Date(Number(date)*1000), "M j, g:i a");;
                        
                        this.update(dateFormatted + '<br />' + storeItem.get('duration'));    
                    }
               }
           }
       ];
   }
});