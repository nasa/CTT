@isTest
public class ChangeCaseOwner_Test {
    
    @isTest
    private static void itFetchesUserList(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CTC Supervisor'];
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser1@pih.org.invalidtest', Team__c='Team 1');
        insert user1;
        
        List<User> users = ChangeCaseOwner.fetchUserList('Testing');
        System.assertEquals(1, users.size());
    }
    
    @isTest
    private static void itFetchesQueueList(){
        List<Group> queues = ChangeCaseOwner.fetchQueueList();
        System.assertNotEquals(0, queues.size());
    }
    
    @isTest
    private static void itUpdatesCaseOwner(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CTC Supervisor'];
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser1@pih.org.invalidtest', Team__c='Team 1');
        insert user1;
        
        user1 = [SELECT id FROM User where LastName='Testing' LIMIT 1];
        
        Group g1 = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName='Positive_Outreach_Queue'];
        
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId, OwnerId=g1.Id);
        insert positiveOutreach;
        
        List<Case> casesToReassign = [SELECT id FROM Case];
        List<String> stringListOfCaseIds = new List<String>();
        
        for(Case cas :casesToReassign){
            stringListOfCaseIds.add(cas.Id);
        }
        
        Integer casesUpdated = ChangeCaseOwner.updateCaseOwner(user1.id,stringListOfCaseIds);
        System.assertEquals(1, casesUpdated);
    }
    
    @isTest
    private static void itHitsCatchBlock(){
               Profile p = [SELECT Id FROM Profile WHERE Name='CTC Supervisor'];
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser1@pih.org.invalidtest', Team__c='Team 1');
        insert user1;
        
        user1 = [SELECT id FROM User where LastName='Testing' LIMIT 1];
        
        Group g1 = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName='Positive_Outreach_Queue'];
        
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId, OwnerId=g1.Id);
        insert positiveOutreach;
        
        List<Case> casesToReassign = [SELECT id FROM Case];
        List<String> stringListOfCaseIds = new List<String>();
        
        for(Case cas :casesToReassign){
            stringListOfCaseIds.add(cas.Id);
        }
        
        try{
           Integer casesUpdated = ChangeCaseOwner.updateCaseOwner(null,stringListOfCaseIds);
         
        } catch (Exception e) {
            
        }
        
        
    }
}