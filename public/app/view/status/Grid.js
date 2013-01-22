Ext.define('AttApi.view.status.Grid', {

    extend: 'Ext.grid.Panel',
    alias: 'widget.status-grid',

    initComponent: function() {
        var me = this;

        Ext.apply(me, {
            store: 'Tests',
            columns: [{
                text: 'Test',
                dataIndex: 'api_name',
                flex: 1
            }, {
                text: 'Duration',
                dataIndex: 'duration',
                width: 70,
                renderer: me.formatDuration
            }, {
                text: 'Result',
                dataIndex: 'result',
                width: 70,
                renderer: me.formatResult
            }]
        });

        this.callParent(arguments);
    },

    /**
     * Result renderer
     * @private
     */
    formatResult: function(value, metaData, record) {
        metaData.tdCls = "result_" + value;

        if (value === 1) {
            return 'Passed';
        }
        else if (value === 2) {
            return 'Warning';
        }
        else {
            return 'Failed';
        }
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
    formatDate: function(date) {
        if (!date) {
            return '';
        }

        var now = new Date(),
            d = Ext.Date.clearTime(now, true),
            notime = Ext.Date.clearTime(date, true).getTime();

        if (notime === d.getTime()) {
            return 'Today ' + Ext.Date.format(date, 'g:i a');
        }

        d = Ext.Date.add(d, 'd', -6);
        if (d.getTime() <= notime) {
            return Ext.Date.format(date, 'D g:i a');
        }
        return Ext.Date.format(date, 'Y/m/d g:i a');
    }
});
