({
    handleChange: function (cmp, event, helper) {
        var selectedVal = event.getSource().get("v.value");
        var selectedName =  event.getSource().get("v.name");
        // console.log('select value:::: '+selectedVal);
        // console.log('select name:::: '+selectedName);
        var appEvent = $A.get("e.c:ACN_AssignPicklistVal");
        appEvent.setParams({
            	"ACN_Question_Identifier": selectedName,
             	"allResponseDetails": selectedVal
        });
        appEvent.fire();
    }
    
})