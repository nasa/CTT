trigger ACN_AutoReplaceLogicReferences on ACN_Screen_Data_Elements__c (after insert) {
    String sObjectName = 'ACN_Screen_Data_Elements__c';
    String externalFieldApiName = 'ACN_External_Ref__c';
    String referencefieldApiName = 'ACN_Question_Identifier__c';
    String formulaFieldApiName = 'ACN_Question_Logic__c';
    if (Trigger.isAfter && Trigger.isInsert) {
        Set<Id> allInsertedIds = trigger.newMap.keySet();
        List<Id> newRecordIds = new List<Id>(allInsertedIds);
        
        // String allRecordsStr = 'SELECT Id, '+ referencefieldApiName +', '+ formulaFieldApiName +', '+ externalFieldApiName +' FROM '+ sObjectName ;
        String newRecordsStr = 'SELECT Id, '+ referencefieldApiName +', '+ formulaFieldApiName +', '+ externalFieldApiName +' FROM '+ sObjectName +' WHERE Id IN :newRecordIds FOR UPDATE';
        
        ACN_AutoReplace.sObjectName = sObjectName;
        ACN_AutoReplace.externalFieldApiName = externalFieldApiName;
        ACN_AutoReplace.referencefieldApiName = referencefieldApiName;
        ACN_AutoReplace.formulaFieldApiName = formulaFieldApiName;
        // ACN_AutoReplace.allRecords = Database.query(allRecordsStr);
        ACN_AutoReplace.newRecords = Database.query(newRecordsStr);
        ACN_AutoReplace.autoReplace();
    }
}