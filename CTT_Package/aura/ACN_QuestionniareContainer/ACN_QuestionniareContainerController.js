({
    doInit : function(component, event, helper) {
        // console.log('RECORD ID:::: '+component.get("v.recordId"));
        // console.log(component.get("v.availableActions")+'::::<< AVAILABLE ActionS:::: '+component.get('v.navigateFlow'));
        // var Response = [];
        var Action = component.get("c.getQuestionDetails");
        Action.setParams({templateId: component.get("v.templateId")});
        Action.setCallback(this, function(resp) {
            
            var State = resp.getState();
            if (State === "SUCCESS") {
                component.set("v.allQuestionMap", resp.getReturnValue());
                // console.log('1st EXTRA PARAMS:::: '+resp.getReturnValue()[0].eachQuesDetails.ACN_Screen__r.ACN_Call_Flow_Template__r.ACN_Extra_Parameters__c);
                var paramString = resp.getReturnValue()[0].eachQuesDetails.ACN_Screen__r.ACN_Call_Flow_Template__r.ACN_Extra_Parameters__c;
                if(paramString !== null){
                    var action2 = component.get("c.getAdditionalParams");
                    action2.setParams({templateId: component.get("v.templateId"),
                                       recordId: component.get("v.recordId"),
                                       paramString: paramString});
                    action2.setCallback(this, function(resp2) {
                        if((resp2.getState() === "SUCCESS")){
                            component.set("v.extraParam", resp2.getReturnValue());
                            helper.createComponent(component, event, helper);
                        }
                    });
                    $A.enqueueAction(action2);
                }
                else {
                    helper.createComponent(component, event, helper);
                }
            }
        });
        $A.enqueueAction(Action);
    },
    handleNavigate: function(component, event) {
        var navigate = component.get("v.navigateFlow");
        navigate(event.getParam("action"));
    }
})