Ext.define('AttApi.view.history.Grid', {
    
    extend  : 'Ext.grid.Panel',
    alias   : 'widget.history-grid',
    title   : 'Raw Data',
    
    initComponent: function() {
        var me = this;
        
        Ext.apply(me, {
            
            columns : [
                {
                    text        : 'Start Time',
                    dataIndex   : 'start_time',
                    renderer    : me.formatDate,
                    flex        : 1
                },
                {
                    text        : 'Duration',
                    dataIndex   : 'duration',
                    width       : 70,
                    renderer    : me.formatDuration
                }, 
                {
                    text        : 'Result',
                    dataIndex   : 'msg',
                    width       : 70,
                    renderer    : me.formatResult
                }
            ],
            
            tools :[
                {
                    type    : 'save',
                    qtip    : 'Export'
                }
            ]
        });

        this.callParent(arguments);
    },

    /**
     * Result renderer
     * @private
     */
    formatResult: function(value, metaData, record) {
        metaData.tdCls = "result_" + value;
        return value;
    },

    formatDetails: function(value, metaData, record) {
        return record.get('start_time');
    },
    
    /**
     * Result renderer
     * @private
     */
    formatDuration: function(value, metaData, record) {
        
        metaData.tdCls = 'yelb';
        
        if (value < 5) {
            metaData.tdCls = 'grnb';
        }
        
        if (value > 8) {
            metaData.tdCls = 'redb';
        }
        
        return value;
    },

    /**
     * Date renderer
     * @private
     */
    formatDate: function(txt) {
        if (!txt) {
            return '';
        }
        return Ext.Date.format(new Date(Number(txt)*1000), 'm/d/Y g:i a');
    }
});

