public virtual class ExposedContactAfterInsertHelperCore implements TriggerFramework.IHandler{
	public void execute(TriggerFramework.Context context) {
        List<Exposed_Contact_Review__c> newList = (List<Exposed_Contact_Review__c>)context.newList;
        Map<Id, Exposed_Contact_Review__c> newMap = (Map<Id, Exposed_Contact_Review__c>)context.newMap;
        
        List<Exposed_Contact_Review__c> oldList = (List<Exposed_Contact_Review__c>)context.oldList;
        Map<Id, Exposed_Contact_Review__c> oldMap = (Map<Id, Exposed_Contact_Review__c>)context.oldMap;
        
        onAfterInsert(newMap);
        
        //invoke child class execute method
        ExposedContactAfterInsertHelper.executeHelper(context);
	}
    
	public virtual void onAfterInsert(Map<Id, Exposed_Contact_Review__c> newExposedContacts){
        ExposedContactReviewTriggerHandler.onAfterInsert(newExposedContacts);
    }    
}