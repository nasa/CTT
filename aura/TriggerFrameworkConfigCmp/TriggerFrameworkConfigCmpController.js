({
    doInit : function(cmp, event, helper) {
        helper.getConfigData(cmp, '');
    },
    
    saveConfig : function(cmp, event, helper) {
        if(helper.checkValidationsHelper(cmp)){
            helper.saveConfigHelper(cmp);
        }
        else{
            alert("Please Fill All Mandatory Fields");
        }
    },
    
    deleteConfig : function(cmp, event, helper) {
        var confirmDelete = window.confirm('If You Delete This Configuration It Will Be Deleted For All Profiles.');
        if(confirmDelete){
            helper.deleteConfigHelper(cmp, event);
        }
        event.stopPropagation();
    },
    
    toggleProfileAccess : function(cmp, event, helper) {
        var selectedProfileId = cmp.get("v.selectedProfileName");
        helper.toggleProfileAccessHelper(cmp, event, selectedProfileId);
    },
    
    editConfig : function(cmp, event, helper) {
        cmp.find("configModalWindowHeader").getElement().innerHTML = "Edit Configuration";
        helper.toggleModalWindowHelper(cmp);
        helper.editConfigHelper(cmp, event);
    },
    
    createClassOrTrigger : function(cmp, event, helper) {
        helper.createClassOrTriggerHelper(cmp, event);
        event.stopPropagation();
    },
    
    renderPage: function(cmp, event, helper) {
        helper.renderPageHelper(cmp);
    },
    
    onchangeNoOfRecords : function(cmp, event, helper) {
        cmp.set("v.pageNumber", 0);
        cmp.set("v.pageNumber", 1);
    },
    
    toggleModalWindow : function(cmp, event, helper) {
        cmp.find("configModalWindowHeader").getElement().innerHTML = "Add New Configuration";
        helper.toggleModalWindowHelper(cmp);
    },
    
    saveProfileConfig : function(cmp, event, helper) {
        helper.saveProfileConfigHelper(cmp);
    },
    
    loadProfileConfigs : function(cmp, event, helper) {
        var selectedProfileId = cmp.get("v.selectedProfileName");
        helper.getConfigData(cmp, selectedProfileId);
    },
})