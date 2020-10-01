({
    getConfigData : function(cmp, selectedProfileId) {
        cmp.set("v.toggleSpinner", true);
        var action = cmp.get('c.getConfigData');
        action.setParams({
            "profileId" : selectedProfileId
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseData = response.getReturnValue();
                if(selectedProfileId == ''){
                    cmp.set('v.profileNameList', responseData.profileList);
                    cmp.set('v.selectedProfileName', responseData.profileList[0].Id);
                    cmp.set('v.configData', responseData.configData);
                }else{
                    cmp.set('v.configData', responseData.configData);
                }
                cmp.set('v.activeProfileIds', responseData.activeProfileIds);
                if(responseData.activeProfileIds.indexOf(cmp.get('v.selectedProfileName')) == -1){
                    cmp.find("toggleProfileAccessButton").set("v.checked", false);
                }else{
                    cmp.find("toggleProfileAccessButton").set("v.checked", true);
                }
                this.renderPageHelper(cmp);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                alert('Something Went Wrong Please Try Again');
            }
            cmp.set("v.toggleSpinner", false);
        }));
        $A.enqueueAction(action);
    },
    
    editConfigHelper : function(cmp, event) {
        var enabledVar = false;
        if(event.currentTarget.children[4].children[0].innerHTML == "true") enabledVar = true;
        var useNewTrans = false;
        if(event.currentTarget.children[6].children[0].innerHTML == "true") useNewTrans = true;
        
        cmp.set("v.configObject",{'sobjectType': 'Trigger_Framework_Config__c',
                                  'Id': event.currentTarget.children[0].children[0].innerHTML,
                                  'DeveloperName': event.currentTarget.children[3].children[0].innerHTML,
                                  'Object_Name__c':event.currentTarget.children[1].children[0].innerHTML,
                                  'Trigger_Event__c':event.currentTarget.children[2].children[0].innerHTML,
                                  'Enabled__c': enabledVar,
                                  'Max_ReEntry__c':event.currentTarget.children[5].children[0].innerHTML,
                                  'Use_New_Transaction__c': useNewTrans,
                                  'Fields__c':event.currentTarget.children[7].children[0].innerHTML,
                                  'HandlerClass_ExecutionOrder__c':event.currentTarget.children[8].children[0].innerHTML,
                                 });
        console.log(cmp.get("v.configObject"));        
    },
    
    saveConfigHelper : function(cmp) {
        cmp.set("v.toggleSpinner", true);
        var newConfigData = cmp.get("v.configObject");
        console.log('newConfigData --'+newConfigData.name);
        //newConfigData.sobjectType = 'Trigger_Framework_Config__c';
        var action = cmp.get('c.createConfig');
        action.setParams({
            "newConfigDataJson" : JSON.stringify(newConfigData),
            "selectedProfileId" : cmp.get("v.selectedProfileName")
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseData = response.getReturnValue();
                if(responseData.state == "success"){
                    cmp.set('v.configData', responseData.configData);
                    this.renderPageHelper(cmp);
                    $A.util.toggleClass(cmp.find("ModalWindowAuraId").getElement(), "slds-hide");
                    alert(responseData.message);
                }else{
                    alert(responseData.message);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                alert('Something Went Wrong Please Try Again');
            }
            cmp.set("v.toggleSpinner", false);
        }));
        $A.enqueueAction(action);
    },
    
    saveProfileConfigHelper : function(cmp) {
        cmp.set("v.toggleSpinner", true);
        var selectedProfileId = cmp.get("v.selectedProfileName");       
        var action = cmp.get('c.saveProfileConfigData');
        action.setParams({
            configsList : cmp.get("v.configData"),
            profileId : selectedProfileId
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseData = response.getReturnValue();
                if(responseData.state == "success"){
                    alert(responseData.message);
                }else{
                    alert(responseData.message);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                alert('Something Went Wrong Please Try Again');
            }
            cmp.set("v.toggleSpinner", false);
        }));
        $A.enqueueAction(action);
    },
    
    createClassOrTriggerHelper : function(cmp, event) {
        cmp.set("v.toggleSpinner", true);
        var componentType = event.currentTarget.innerHTML;
        var triggerOrHelperName = event.currentTarget.getAttribute("title");
        var action = cmp.get('c.classOrTrigger');
        action.setParams({
            "triggerOrHelperName" : triggerOrHelperName,
            "componentType" : componentType
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseData = response.getReturnValue();
                if(responseData.state == "success"){
                    alert(responseData.message);
                }else{
                    alert(responseData.message);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                alert('Something Went Wrong Please Try Again:');
            }
            cmp.set("v.toggleSpinner", false);
        }));
        $A.enqueueAction(action);
    },
    
    toggleModalWindowHelper : function(cmp) {
        cmp.set("v.configObject",{'sobjectType': 'Trigger_Framework_Config__c',
                                  'Id': null,
                                  'DeveloperName': '',
                                  'Object_Name__c':'',
                                  'Trigger_Event__c':'BeforeInsert',
                                  'Enabled__c':'true',
                                  'Max_ReEntry__c':'1',
                                  'Fields__c':'',
                                  'Use_New_Transaction__c':''
                                 });
        $A.util.toggleClass(cmp.find("ModalWindowAuraId").getElement(), "slds-hide");
    },
    
    renderPageHelper: function(cmp) {
        var pageNumber = cmp.get("v.pageNumber");
        if(!isNaN(pageNumber) && pageNumber != 0){
            var records = cmp.get("v.configData");
            var noOfRecordPerPage = cmp.get("v.noOfRecordPerPage");
            cmp.set("v.maxPage", Math.ceil((records.length)/noOfRecordPerPage));
            var pageRecords = records.slice((pageNumber-1)*noOfRecordPerPage, pageNumber*noOfRecordPerPage);
            cmp.set("v.selectedRecordsRange", pageRecords);
        }
    },
    
    toggleProfileAccessHelper : function(cmp, event, selectedProfileId) {
        debugger;
        cmp.set("v.toggleSpinner", true);
        var accessType = event.getSource().get("v.checked");
        var action = cmp.get('c.toggleProfileAcess');
        action.setParams({
            "selectedProfileId" : selectedProfileId,
            "accessType" : accessType
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseData = response.getReturnValue();
                if(responseData.state == "success"){
                    //alert(responseData.message);
                }else{
                    cmp.find("toggleProfileAccessButton").set("v.checked", !accessType);
                    alert(responseData.message);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                cmp.find("toggleProfileAccessButton").set("v.checked", !profileToggleState);
                alert('Something Went Wrong Please Try Again');
            }
            cmp.set("v.toggleSpinner", false);
        }));
        $A.enqueueAction(action);
    },
    
    deleteConfigHelper : function(cmp, event) {
        cmp.set("v.toggleSpinner", true);
        var recordId = event.getSource().get("v.value");
        var action = cmp.get('c.deleteConfigData');
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseData = response.getReturnValue();
                if(responseData.state == "success"){
                    var configData = cmp.get("v.configData");
                    for(var i in configData){
                        if(configData[i].Id == recordId){
                            configData.splice(i, 1);
                            break;
                        }
                    }
                    cmp.set('v.configData', configData);
                    this.renderPageHelper(cmp);
                    alert(responseData.message);
                }else{
                    alert(responseData.message);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                alert('Something Went Wrong Please Try Again');
            }
            cmp.set("v.toggleSpinner", false);
        }));
        $A.enqueueAction(action);
    },
    
    checkValidationsHelper : function(cmp) {
        var auraIdList = ["helperNameAuraId","objectNameAuraId"];
        var errorMsg1 = "This Field Is Mandatory";
        var validationErrorCount = 0;
        for(var i=0;i<auraIdList.length;i++){
            var fieldCmp = cmp.find(auraIdList[i]);
            var fieldCmpValue = fieldCmp.get("v.value");
            if(fieldCmpValue==""){
                validationErrorCount++;
                fieldCmp.set("v.messageWhenValueMissing", errorMsg1);
            }else{
                fieldCmp.set("v.messageWhenValueMissing", null);
            }
        }
        if(validationErrorCount > 0){
            return false;
        }else{
            return true;
        }
    },    
})