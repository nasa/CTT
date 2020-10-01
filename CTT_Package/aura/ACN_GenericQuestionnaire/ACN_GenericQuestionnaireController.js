({
    doInit : function(component, event, helper) {
        // console.log('Child::: '+JSON.stringify(component.get("v.allQuestionMap")));
        // console.log('EXTRA PARAMS:::: '+JSON.stringify(component.get("v.extraParam")));
        // console.log('RECORD ID:::: '+component.get("v.recordId"));
        var allQues = component.get("v.allQuestionMap");
        component.set("v.tempTemplateIdStr", component.get("v.templateId"));
        var a = component.get("c.getProgressPath");
        $A.enqueueAction(a);
        for(var i=0; i < allQues.length;i++) {
            if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_isStartScreen__c) {
                
                //Added by Ranjan
                if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_isStartScreen__c && allQues[i].eachQuesDetails.ACN_Screen__r.Hide_Next__c ){
                    component.set("v.isNext", false);
                    component.set("v.previousScreenNo", allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c);
                    component.set("v.screenNo", allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c);
                    // component.set("v.screenProgressNo",allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Stage_Sequence_No__c);
                    // console.log("@@@@@@@@@@@@@@!!!!!!!!!!!!!! : " + component.get("v.screenProgressNo"));
                    // component.set("v.screenProgressName",allQues[i].eachQuesDetails.Screen__r.ACN_Stage_Name__c);
                    helper.displayQuestions(component, event, allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c, '');
                    
                } //Added by Ranjan
                else{
                    component.set("v.previousScreenNo", allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c);
                    component.set("v.screenNo", allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c);
                    // component.set("v.screenProgressNo",allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Stage_Sequence_No__c);
                    // console.log("@@@@@@@@@@@@@@!!!!!!!!!!!!!! : " + component.get("v.screenProgressNo"));
                    // component.set("v.screenProgressName",allQues[i].eachQuesDetails.Screen__r.ACN_Stage_Name__c);
                    helper.displayQuestions(component, event, allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c, '');
                }
                break;
            }
        }
    },
    // capture the response for each questions that's answered locally in 'allResponseDetails'
    // also evaluate the other questions for their display criteria
    changeValue : function(component, event, helper, Source) {
        helper.changeValue(component, event, 'onClickEvt');
    },
    // navigate to previous screen with its response intact
    // repaint the screen with relevant screen questions
    previousClick : function(component, event, helper) {        
        var standardPrevious = component.get("v.standardPrevious");
        // console.log("standardPrevious ::" + standardPrevious);
        if(standardPrevious){
            var actionClicked = event.getSource().getLocalId();
            var navigate = component.getEvent("navigateFlowEvent");
            navigate.setParam("action", actionClicked);
            navigate.fire();
        }
        else{
            // console.log('If it is not standard previous'); //Added by Ranjan
            var QuesRespMap = component.get("v.QuesRespMap");
            var allQues = component.get("v.allQuestionMap");
            // component.set("v.body", "");
            // console.log('screen previous:: ' + component.get("v.previousScreenNo")+'....'+component.get("v.screenNo"));
            var screenNo = component.get("v.screenNo");
            var tempTemplateId = component.get("v.tempTemplateId");
            tempTemplateId.pop();
            component.set("v.tempTemplateId", tempTemplateId);
            helper.createStageSet(component);
            var thisTemplateID;
            var progressPath = component.get("v.StageMap");
            
            // this loop is to exclude the ques which is on current screen before the previous button is clicked..
            // we do not want to save the ques that may not be a part of the assessment process..
            for(var i=0;i<allQues.length;i++) {
                if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c === screenNo) {
                    if(QuesRespMap.includes(allQues[i].eachQuesDetails.ACN_Question_Identifier__c)){
                        // QuesRespMap.push(event.getSource().get("v.name"));
                        QuesRespMap = QuesRespMap.filter(function(value, index, arr){
                            return (value !== allQues[i].eachQuesDetails.ACN_Question_Identifier__c);
                        });
                    }
                    thisTemplateID = allQues[i].callFlowTemplateId;
                    component.set("v.previousScreenNo", allQues[i].previousScreenNo);
                    // console.log('allQues[i].previousScreenNo:::'+component.get("v.previousScreenNo")+'::::'+allQues[i].previousScreenNo);
                    // break;
                }
            }            
            component.set("v.QuesRespMap", QuesRespMap);
            var previousScreenNo = component.get("v.previousScreenNo");
            for(var i=0;i<allQues.length;i++) {                
                if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c === previousScreenNo) {
                    // update the progress pin to point to the relevant stage
                    for(var z=0; z<progressPath.length; z++) {
                        if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Stage_Name__c === progressPath[z].value) {
                            component.set("v.screenProgressNo", progressPath[z].key);
                        }
                    }
                    // hide/show the previous button
                    if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_isStartScreen__c && allQues[i].callFlowTemplateId === component.get("v.primaryTemplateId")){
                        component.set("v.isPrevious", false);
                        component.set("v.standardPrevious", true);
                        component.set("v.isNext", true); //Added by Ranjan
                    }
                    // hide/show the previous, next & finish button
                    if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_isEndScreen__c && allQues[i].callFlowTemplateId === component.get("v.primaryTemplateId")){
                        component.set("v.isFinish", true);
                        component.set("v.isNext", false);
                        component.set("v.isPrevious", false);
                    }
                    break;
                }
            }
            helper.displayQuestions(component, event, previousScreenNo, 'PREVIOUS');
        }
    },
    // navigate to next screen as per the Screen Logic/Default Screen value
    nextClick : function(component, event, helper) {
        component.set("v.isPrevious", true);
        component.set("v.standardPrevious", false);
        component.set("v.isNext", true);
        component.set("v.previousScreenNo", component.get("v.screenNo"));
        // console.log('PRE::: '+component.get("v.previousScreenNo"));
        var allQues = component.get("v.allQuestionMap");
        // helper.solveExpression(cc, allQues[0].eachQuesDetails.ACN_Screen__r.ACN_Screen_Logic__c, allQues[0].eachQuesDetails.ACN_Screen__r.ACN_Default_Action_Screen__c);
        var templateFound = false;
        var progressPath = component.get("v.StageMap");        
        for(var i=0;i<allQues.length;i++) {
            if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c === component.get("v.screenNo")){
                component.set("v.screenNo", helper.solveExpression(component, allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Logic__c, allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Default_Action_Screen__c, ''));
                break;
            }
        }
        for(var i=0;i<allQues.length;i++) {
            if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c === component.get("v.screenNo")){
                var tempTemplateId = component.get("v.tempTemplateId");
                tempTemplateId.push(allQues[i].callFlowTemplateId);
                component.set("v.tempTemplateId", tempTemplateId);
                helper.createStageSet(component);
                // update the progress pin to point to the relevant stage
                for(var z=0; z<progressPath.length; z++) {
                    if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Stage_Name__c === progressPath[z].value) {
                        component.set("v.screenProgressNo", progressPath[z].key);
                    }
                }
                //allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Stage_Sequence_No__c);
                component.set("v.screenProgressName", allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Stage_Name__c);
                templateFound = true;
                // hide/show the previous button
                if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_isStartScreen__c && allQues[i].callFlowTemplateId === component.get("v.primaryTemplateId")){
                    // console.log('Inside the if condition by Ranjan' +allQues[i].callFlowTemplateId);//added by Ranjan
                    component.set("v.isPrevious", false);
                }
                // hide/show the previous, next & finish button
                if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_isEndScreen__c && allQues[i].callFlowTemplateId === component.get("v.primaryTemplateId")){
                    component.set("v.isFinish", true);
                    component.set("v.isNext", false);
                    component.set("v.isPrevious", false);
                }
                //Added by Ranjan
                if(allQues[i].eachQuesDetails.ACN_Screen__r.Hide_Next__c && allQues[i].callFlowTemplateId === component.get("v.primaryTemplateId")){
                    component.set("v.isFinish", false);
                    component.set("v.isNext", false);
                    component.set("v.isPrevious", true);
                    
                }
                break;
            }
        }
        // call apex if there is change of template
        if(!templateFound) {
            component.set("v.isPrevious", true);
            var action1 = component.get("c.getNewTemplateDetails");
            action1.setParams({screenNo : component.get("v.screenNo")});
            action1.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var newTempID = response.getReturnValue()[0].callFlowTemplateId;
                    // component.set("v.templateId", newTempID); // commented by Kewal on 30/09
                    // console.log(JSON.stringify(response.getReturnValue()));
                    
                    if(!component.get("v.tempTemplateId").includes(newTempID)){
                        component.set("v.tempTemplateIdStr", newTempID);
                        var newQues = component.get("v.allQuestionMap").concat(response.getReturnValue());
                    }
                    component.set("v.allQuestionMap", newQues);
                    
                    /* for(var i=0; i < newQues.length;i++) {
                        if(newQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c === component.get("v.screenNo") && newQues[i].eachQuesDetails.ACN_Screen__r.ACN_isStartScreen__c) {
                            component.set("v.screenProgressNo", component.get("v.screenProgressNo")+1); // component.set("v.screenProgressNo",newQues[i].eachQuesDetails.ACN_Screen__r.ACN_Stage_Sequence_No__c);
                            component.set("v.screenProgressName",newQues[i].eachQuesDetails.ACN_Screen__r.ACN_Stage_Name__c);
                            break;
                        }
                    } */
                    var paramString = response.getReturnValue()[0].eachQuesDetails.ACN_Screen__r.ACN_Call_Flow_Template__r.ACN_Extra_Parameters__c;
                    // console.log('2nd EXTRA PARAMS:::: '+paramString);
                    if(paramString !== null){
                        // get extra parameter/s for new template and append to the existing ones
                        var action2 = component.get("c.getAdditionalParams");
                        action2.setParams({templateId: newTempID,
                                           recordId: component.get("v.recordId"),
                                           paramString: paramString});
                        action2.setCallback(this, function(resp2) {
                            if((resp2.getState() === "SUCCESS")){
                                var oldParams = component.get("v.extraParam");
                                var newextraParams = resp2.getReturnValue(); // component.get("v.extraParam").concat(resp2.getReturnValue());
                                // if(newextraParams != null){
                                    for(var i=0; i<newextraParams.length;i++){
                                        // console.log(oldParams.some(item => (item.key === newextraParams[i].key && item.templateId === newextraParams[i].templateId)));
                                        if(!oldParams.some(item => (item.key === newextraParams[i].key && item.templateId === newextraParams[i].templateId))){
                                            oldParams.push(newextraParams[i]);
                                        }
                                    }
                                    component.set("v.extraParam", oldParams);
                                // }
                                helper.displayQuestions(component, event, component.get("v.screenNo"), 'NEXT');
                            }
                        });
                        $A.enqueueAction(action2);
                    }
                    else{
                        helper.displayQuestions(component, event, component.get("v.screenNo"), 'NEXT');
                    }
                }
            });
            $A.enqueueAction(action1);
        }
        else {
            helper.displayQuestions(component, event, component.get("v.screenNo"), 'NEXT');
        }        
    },
    finishClick : function(component, event, helper) {
        // console.log('FINSIHED.......'+event.getSource().getLocalId());
        helper.saveQuestions(component, '');        
        var actionClicked = event.getSource().getLocalId();
        var navigate = component.getEvent("navigateFlowEvent");
        navigate.setParam("action", actionClicked);
        navigate.fire();
    },
    getProgressPath : function(component, event, helper) {
        var oldProgressPath = component.get("v.StageMap");
        var newProgressPath = [];
        var templateId = component.get("v.tempTemplateIdStr");
        var tempTemplateId = component.get("v.tempTemplateId");
        tempTemplateId.push(templateId);
        component.set("v.tempTemplateId", tempTemplateId);
        // console.log('OOOO:::: '+oldProgressPath);
        var action1 = component.get("c.getProgressPathDetails");
        action1.setParams({templateId: templateId});
        action1.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                // console.log('StageMap:::: '+JSON.stringify(response.getReturnValue()));
                var allProgressPath= response.getReturnValue();
                for(var key in allProgressPath) {
                    newProgressPath.push({
                        key : parseInt(key),
                        value : allProgressPath[key],
                        templateId : templateId
                    });
                }
                // console.log('StageMap:::: '+JSON.stringify(oldProgressPath));
                var tempStages =  [];
                for(var i=0; i<oldProgressPath.length;i++) {
                    if(i >= component.get("v.screenProgressNo")) {
                        tempStages.push(oldProgressPath[i]);
                    }
                }
                oldProgressPath = oldProgressPath.filter(function(value, index, arr){
                    return (index < component.get("v.screenProgressNo"));
                });
                for(var i=0; i<newProgressPath.length;i++) {
                    oldProgressPath.push(newProgressPath[i]);
                }
                for(var i=0; i<tempStages.length;i++) {
                    oldProgressPath.push(tempStages[i]);
                }
                component.set("v.StageMap", oldProgressPath);
                helper.renumberStage(component, event, helper);
                helper.createStageSet(component);
                component.set("v.screenProgressNo", component.get("v.screenProgressNo")+1);
            }
        });
        $A.enqueueAction(action1);
    },
    handleEvent : function(component, event, helper) {
        // console.log("in handleEvent");
        // console.log("Identifier:::: "+event.getParam("ACN_Question_Identifier"));
        // console.log("Value:::: "+event.getParam("allResponseDetails"));
        helper.changeValue(component, event, 'AppEvent');
    }
})