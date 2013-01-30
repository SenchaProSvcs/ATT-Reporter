Ext.application({
    models: [
        'TestExecution',
        'TestResult'
    ],
    stores: [
        'LastTestResults',
        'TestResults'
    ],
    views: [
        'Viewport'
    ],
    controllers: [
        'Main'
    ],
    name: 'Reporter',
    autoCreateViewport: true
});
