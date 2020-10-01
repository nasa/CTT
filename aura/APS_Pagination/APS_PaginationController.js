({
    firstPage: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
    },
    prevPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.max(component.get("v.currentPageNumber")-1, 1));
    },
    nextPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.min(component.get("v.currentPageNumber")+1, component.get("v.maxPageNumber")));
    },
    lastPage: function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
    },
    enterPage : function(component, event, helper){
        var enteredValue = event.getSource().get('v.value');
        if(enteredValue > component.get("v.maxPageNumber")){
            event.getSource().set('v.value', component.get("v.maxPageNumber"));
        }/*else if(enteredValue < 1){
            event.getSource().set('v.value', 1);
        }*/else if(isNaN(enteredValue)){
            event.getSource().set('v.value', 1);
        }
    }
})