Ext.application({
    models: [
        'TestExecution',
        'TestResult'
    ],
    stores: [
        'LastTestResults',
        'TestExecutions',
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
