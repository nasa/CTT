@isTest
public with sharing class ContactTracerTriggerHadler_Test {
    @isTest
    static void testGetCaseDetails() {
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        
        Id personAccountRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Group g1 = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName='Positive_Outreach_Queue'];
        
        Account acc = new Account(FirstName='Person1', LastName='Acct1', RecordTypeId=personAccountRtId);
        insert acc;
        Account updacc = new Account(FirstName='Person2', LastName='Acct2', RecordTypeId=personAccountRtId);
        insert updacc;
        
        // System.debug(positiveOutreach);
        
        Test.startTest();            
        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=recordTypeId, OwnerId=g1.Id, AccountId=acc.Id);
        insert positiveOutreach; 
        positiveOutreach.AccountId = updacc.id;
        update positiveOutreach;
        Test.stopTest();
        positiveOutreach = [SELECT contactId FROM Case WHERE Id =: positiveOutreach.Id];
    //    System.assertEquals(acc.personcontactid, positiveOutreach.contactId);
        
    }
    
}