({
	doinit:function(component,event){
        
        var rid = component.get("v.recordId");
        var action = component.get("c.updateDefaultAction");
        action.setParams({"templateId" : rid});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log("success");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    console.log("Error");
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    
    closeClick: function(component,event){
     	var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();   
    }
})