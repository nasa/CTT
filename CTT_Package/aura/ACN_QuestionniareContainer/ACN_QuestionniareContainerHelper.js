({
    createComponent : function(component, event, helper){
        $A.createComponent(
            "c:ACN_GenericQuestionnaire", {
                "allQuestionMap" : component.get("v.allQuestionMap"),
                "extraParam" : component.get("v.extraParam"),
                "availableActions" : component.get("v.availableActions"),
                "navigateFlowEvent" : component.getReference("c.handleNavigate"),
                "primaryTemplateId" : component.get("v.templateId"),
                "StageMap" : component.get("v.StageMap"),
                "association" : component.get("v.association"),
                "templateId" : component.get("v.templateId"),
                "recordId" : component.get("v.recordId"),
                "standardPrevious" : component.get("v.standardPrevious")
            },
            function(newcomponent, status, message){
                if (status === "SUCCESS" && component.isValid()) {
                    var Body = component.get("v.body");
                    Body.push(newcomponent);
                    component.set("v.body", Body);
                }
            }
        );
    }
})