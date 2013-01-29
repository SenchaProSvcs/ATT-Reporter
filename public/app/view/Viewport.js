Ext.define('Reporter.view.Viewport', {
    renderTo: Ext.getBody(),
    extend: 'Ext.container.Viewport',
    requires: [
        'Ext.chart.axis.Numeric',
        'Ext.chart.Chart',
        'Ext.chart.series.Column',
        'Ext.form.field.TextArea',
        'Ext.grid.column.Date',
        'Ext.grid.feature.Grouping',
        'Ext.grid.Panel',
        'Ext.layout.container.Border'
    ],
    
    cls: 'r-viewport',
    layout: 'border',
    items: [{
        xtype: 'container',
        region: 'north',
        cls: 'logo',
        height: 90,
        weight: 200,
        margins: '0 0 40 0'
    },{
        xtype: 'gridpanel',
        itemId: 'last-results-grid',
        region: 'west',
        weight: 200,
        width: 500,
        margins: '0 10 20 20',
        store: 'LastTestResults',
        split: true,
        features: [{
            ftype:'grouping',
             groupHeaderTpl: '{name}',
             enableGroupingMenu: false,
             collapsible: false
        }],
        dockedItems: [{
            xtype: 'component',
            dock: 'top',
            cls: 'api-status-header',
            itemId: 'api-status-header',
            tpl: '<h2>APIs Status</h2><span>Last Update: {lastUpdate:date("n/j/Y H:iA")}</span>',
            height: 60,
            data: {
                lastUpdate: null
            }
        }],
        columns: [{
            text: 'Method',
            dataIndex: 'name',
            flex: 1
        },{
            xtype: 'datecolumn',
            text: 'Start',
            dataIndex: 'created_date',
            align: 'center',
            format: 'H:i:s.u',
            width: 90
        },{
            xtype: 'datecolumn',
            text: 'Finish',
            dataIndex: 'finished_date',
            align: 'center',
            format: 'H:i:s.u',
            width: 90
        },{
            text: 'Duration',
            dataIndex: 'duration',
            align: 'center',
            width: 70,
            renderer: function(v) {
                return v + 's';
            }
        },{
            text: 'Result',
            dataIndex: 'result',
            align: 'center',
            width: 70,
            renderer: function(v, meta) {
                switch(v) {
                    case Reporter.model.TestResult.PASSED:
                        meta.style = "color: #62B851; font-weight: bold;";
                        return 'Passed';
                        
                    case Reporter.model.TestResult.WARNING:
                        meta.style = "color: #D6CF21; font-weight: bold;";
                        return 'Warning';
                }
                
                meta.style = "color: #DD2B2B; font-weight: bold;";
                return 'Error';
            }
        }]
    },{
        xtype: 'panel',
        layout: 'fit',
        region: 'center',
        margins: '60 20 10 10',
        items: {
            xtype: 'chart',
            store: 'TestResults',
            animate: true,
            axes: [{
                type: 'Numeric',
                position: 'left',
                fields: ['duration'],
                minimum: 0,
                grid: true
            }],
            series: [{
                type: 'column',
                axis: 'left',
                highlight: true,
                xField: 'created_date',
                yField: 'duration',
                label: {
                  display: 'insideEnd',
                  'text-anchor': 'middle',
                  field: 'duration',
                  renderer: Ext.util.Format.numberRenderer('0'),
                  orientation: 'vertical',
                  color: '#333'
                }
            }]
        }
    },{
        xtype: 'panel',
        region: 'south',
        weight: 100,
        flex: 1,
        margins: '10 20 20 10',
        split: true,
        layout: {
            type: 'hbox',
            align: 'stretch'
        },
        defaults: {
            flex: 1
        },
        items: [{
            xtype: 'gridpanel',
            itemId: 'results-details-grid',
            store: 'TestResults',
            border: false,
            columns: [{
                xtype: 'datecolumn',
                text: 'Start',
                dataIndex: 'created_date',
                align: 'center',
                format: 'H:i:s.u',
                width: 90
            },{
                xtype: 'datecolumn',
                text: 'Finish',
                dataIndex: 'finished_date',
                align: 'center',
                format: 'H:i:s.u',
                width: 90
            },{
                text: 'Duration',
                dataIndex: 'duration',
                align: 'center',
                width: 70,
                renderer: function(v) {
                    return v + 's';
                }
            },{
                text: 'Result',
                dataIndex: 'result',
                align: 'center',
                width: 70,
                renderer: function(v, meta) {
                    switch(v) {
                        case Reporter.model.TestResult.PASSED:
                            meta.style = "color: #62B851; font-weight: bold;";
                            return 'Passed';
                        
                        case Reporter.model.TestResult.WARNING:
                            meta.style = "color: #D6CF21; font-weight: bold;";
                            return 'Warning';
                    }
                
                    meta.style = "color: #DD2B2B; font-weight: bold;";
                    return 'Error';
                }
            }]     
        },{
            xtype: 'splitter',
            flex: 0,
            style: 'border: 1px solid #DDD; border-width: 0 1px;'
        },{
            xtype: 'textarea',
            itemId: 'log-container',
            fieldStyle: 'border: none;',
            autoScroll: true
        }]   
    }]
});