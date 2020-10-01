({
    doInit : function(component, event, helper) {
        
        // console.log('RECORDID:::: '+component.get("v.recordId"));
        if(component.get("v.recordId")){
            // alert('RECORD ID NOT NULL');
            var action1 = component.get("c.getRecordDetails");
            action1.setParams ({recordId: component.get("v.recordId")});
            action1.setCallback(this, function(resp) {
                // var state = resp.getState();
                if (resp.getState() === "SUCCESS") {
                    component.set("v.greetName", resp.getReturnValue().Name);
                    // console.log('>>>> '+resp.getReturnValue().Name);
                }
            });
            $A.enqueueAction(action1);
        }
        
        var action = component.get("c.getTemplates")
        action.setCallback(this, function(resp) {
            var state = resp.getState();
            // console.log("state::" + state);
            if (state === "SUCCESS") {
                var ListofTemplates= [];
                var response = resp.getReturnValue();
                component.set("v.TemplateDetails", response);
                // console.log("TemplateDetails" + component.get("v.TemplateDetails"));
                for(var i = 0; i < response.length; i++) {
                    ListofTemplates.push({label: response[i].Name, value: response[i].Id});
                }
                component.set("v.ListofTemplates", ListofTemplates);
            }
        });
        $A.enqueueAction(action);
    },
    selectRadio: function(component, event, helper) {
        // console.log(event.getSource().get("v.value"));
        component.set("v.selectedTemplate", event.getSource().get("v.value"));
        component.set("v.standardPrevious", true);
    },
    handlerClick: function(component, event, helper) {
      var actionClicked = event.getSource().getLocalId();
      var navigate = component.get('v.navigateFlow');
      navigate(actionClicked);
    }

})