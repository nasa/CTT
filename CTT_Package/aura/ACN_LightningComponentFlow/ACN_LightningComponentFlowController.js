({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var recordId = '0013h000004GtQiAAK'; // component.get("v.recordId");
        var templateId = component.get("v.templateId");
        console.log('ACN_LightningComponentFlow RECORDID:::: '+recordId);
        console.log('@@@ '+templateId);
        var inputVariables = [{name : 'recordId', type : 'String', value : recordId},
                              {name : 'TemplateId', type : 'String', value : templateId}];
        
        var flowapi = component.get("v.flowapi");
        flow.startFlow(flowapi, inputVariables);
    },
})