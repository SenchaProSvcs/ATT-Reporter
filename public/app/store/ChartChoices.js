Ext.define('AttApi.store.ChartChoices', {
    
    extend  : 'Ext.data.Store',
    model   : 'AttApi.model.ChartChoice',

    data    : [
        {id: 'BarStackedChart',         name: 'Bar Stacked'},
        {id: 'BarUnstackedChart',       name: 'Bar Unstacked'},
        {id: 'ColumnStackedChart',      name: 'Column Stacked'},
        {id: 'ColumnUnstackedChart',    name: 'Column Unstacked'},
        {id: 'LineChart',               name: 'Line'}
    ]

});