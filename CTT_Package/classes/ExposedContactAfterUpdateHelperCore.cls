public virtual class ExposedContactAfterUpdateHelperCore implements TriggerFramework.IHandler{
	public void execute(TriggerFramework.Context context) {
        List<Exposed_Contact_Review__c> newList = (List<Exposed_Contact_Review__c>)context.newList;
        Map<Id, Exposed_Contact_Review__c> newMap = (Map<Id, Exposed_Contact_Review__c>)context.newMap;
        
        List<Exposed_Contact_Review__c> oldList = (List<Exposed_Contact_Review__c>)context.oldList;
        Map<Id, Exposed_Contact_Review__c> oldMap = (Map<Id, Exposed_Contact_Review__c>)context.oldMap;
        
        onAfterUpdate(oldMap, newMap);
            
        //invoke child class execute method
        ExposedContactAfterUpdateHelper.executeHelper(context);
        
	}

    public virtual void onAfterUpdate(Map<Id, Exposed_Contact_Review__c> oldMap, Map<Id, Exposed_Contact_Review__c> newMap){
        ExposedContactReviewTriggerHandler.onAfterUpdate(oldMap, newMap);
    }
        
}