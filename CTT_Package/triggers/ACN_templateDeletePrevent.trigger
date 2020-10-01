trigger ACN_templateDeletePrevent on ACN_Call_Flow_Template__c (before delete) {
    
    Set<Id> templateId = trigger.oldMap.keySet(); 
    
    system.debug('>>>>'+templateId);
    
    Map<id,ACN_Call_Flow_Screen__c> templateToScreen = new Map<id,ACN_Call_Flow_Screen__c>();
    for(ACN_Call_Flow_Screen__c inc1 :[select id,name,ACN_Call_Flow_Template__c from ACN_Call_Flow_Screen__c where ACN_Call_Flow_Template__c IN : templateId])
        templateToScreen.put( inc1.ACN_Call_Flow_Template__c,inc1);
    System.debug('>>>Map Details'+templateToScreen);
    //list<ACN_Call_Flow_Screen__c> screenList = [select id from ACN_Call_Flow_Screen__c where ACN_Call_Flow_Template__c NOT IN : templateId];
    
    System.debug('>>>Old Trigger'+Trigger.old);
    
    for(ACN_Call_Flow_Template__c tmp1 : Trigger.old)
    {
        System.debug('>>>Status List'+tmp1.ACN_Status__c);
        
        if(templateToScreen.containsKey(tmp1.Id))        
        {            
            tmp1.adderror('You cannot delete a template with Screens associated with it.');
        } 
        else if(tmp1.ACN_Status__c =='Active'){
            tmp1.adderror('You cannot delete an Active template. Please contact your Salesforce Admin.');            
        }
        system.debug('this is the key value'+templateToScreen.get(tmp1.Id));
    }
}