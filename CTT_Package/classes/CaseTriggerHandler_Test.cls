@isTest(SeeAllData = false)
public class CaseTriggerHandler_Test{

    static testMethod void testUpdateTeam() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Case Investigator'];
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser1@pih.org.invalidtest', Team__c='Team 1');
        insert user1;
        
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        
        Group g1 = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName='Positive_Outreach_Queue'];
        
        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId, OwnerId=g1.Id);
        insert positiveOutreach;
        
        System.debug(positiveOutreach);
        
        Test.startTest();
        
            positiveOutreach.OwnerId=user1.Id;
            update positiveOutreach;
        
        Test.stopTest();
        
        user1 = [SELECT Id, Team__c FROM User WHERE Id = :user1.Id];
        positiveOutreach = [SELECT Id, Team__c FROM Case WHERE Id =: positiveOutreach.Id];
        //System.assertEquals(user1.Team__c, positiveOutreach.Team__c);
    }
    
    static testMethod void testInsertContactOutreach() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Case Investigator'];
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser1@pih.org.invalidtest', Team__c='Team 1');
        insert user1;
        
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        Id rtId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Contact_Outreach').getRecordTypeId();
        
        Group g1 = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName='Positive_Outreach_Queue'];
        
        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId, OwnerId=g1.Id);
        insert positiveOutreach;
        
        System.debug(positiveOutreach);
                
        positiveOutreach.OwnerId=user1.Id;
        update positiveOutreach;
        
        Test.startTest();
            Case contactOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId2, ParentId=positiveOutreach.Id,
                                            Last_Name__c='Test Contact', First_Name__c='Dave');
            insert contactOutreach;
        Test.stopTest();
        
        user1 = [SELECT Id, Team__c FROM User WHERE Id = :user1.Id];
        contactOutreach = [SELECT Id, Team__c FROM Case WHERE Id =: contactOutreach.Id];
        
        //System.assertEquals(user1.Team__c, contactOutreach.Team__c);
        
    }
    
    static testMethod void testInsertContactOutreachWithLastExposureDate() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Case Investigator'];
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser1@pih.org.invalidtest', Team__c='Team 1');
        insert user1;
        
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        Id rtId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Contact_Outreach').getRecordTypeId();
        
        Group g1 = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName='Positive_Outreach_Queue'];
        
        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId, OwnerId=g1.Id);
        insert positiveOutreach;
        
        System.debug(positiveOutreach);
                
        positiveOutreach.OwnerId=user1.Id;
        update positiveOutreach;
        
        Test.startTest();
            Case contactOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId2, ParentId=positiveOutreach.Id,
                                            Last_Name__c='Test Contact', First_Name__c='Dave', Last_Exposure_Date__c=Date.today().addDays(-5));
            insert contactOutreach;
        Test.stopTest();
        
        user1 = [SELECT Id, Team__c FROM User WHERE Id = :user1.Id];
        contactOutreach = [SELECT Id, Team__c FROM Case WHERE Id =: contactOutreach.Id];
        
       // System.assertEquals(user1.Team__c, contactOutreach.Team__c);
        
    }
    
    static testMethod void testInsertLocationOutReach() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Case Investigator'];
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser1@pih.org.invalidtest', Team__c='Team 1');
        insert user1;
        
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        Id rtId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Location_Outreach').getRecordTypeId();
        
        Group g1 = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName='Positive_Outreach_Queue'];
        
        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId, OwnerId=g1.Id);
        insert positiveOutreach;
        
        System.debug(positiveOutreach);
                
        positiveOutreach.OwnerId=user1.Id;
        update positiveOutreach;
        
        Test.startTest();
            Case locationOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId2, ParentId=positiveOutreach.Id,
                                            Location_Name__c='Public Library');
            insert locationOutreach;
        Test.stopTest();
        
        user1 = [SELECT Id, Team__c FROM User WHERE Id = :user1.Id];
        locationOutreach = [SELECT Id, Team__c FROM Case WHERE Id =: locationOutreach.Id];
        
        //System.assertEquals(user1.Team__c, locationOutreach.Team__c);
        
    }
    
    static testMethod void testInsertLocationOutReachWithLastExposureDate() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Case Investigator'];
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser1@pih.org.invalidtest', Team__c='Team 1');
        insert user1;
        
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        Id rtId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Location_Outreach').getRecordTypeId();
        
        Group g1 = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName='Positive_Outreach_Queue'];
        
        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId, OwnerId=g1.Id);
        insert positiveOutreach;
        
        System.debug(positiveOutreach);
                
        positiveOutreach.OwnerId=user1.Id;
        update positiveOutreach;
        
        Test.startTest();
            Case locationOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId2, ParentId=positiveOutreach.Id,
                                            Location_Name__c='Public Library', Last_Exposure_Date__c=Date.today().addDays(-5));
            insert locationOutreach;
        Test.stopTest();
        
        user1 = [SELECT Id, Team__c FROM User WHERE Id = :user1.Id];
        locationOutreach = [SELECT Id, Team__c FROM Case WHERE Id =: locationOutreach.Id];
        
        //System.assertEquals(user1.Team__c, locationOutreach.Team__c);
        
    }

    static testMethod void testSyncCongregateSetting() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Case Investigator'];
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser1@pih.org.invalidtest', Team__c='Team 1');
        insert user1;
        
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        
        Group g1 = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName='Positive_Outreach_Queue'];
        
        Id personAccountRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Account acc = new Account(FirstName='Robert', LastName='Browning', RecordTypeId=personAccountRtId);
        insert acc;

        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];

        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId, OwnerId=g1.Id, ContactId=con.Id);
        insert positiveOutreach;
        
        System.debug(positiveOutreach);
        
        Test.startTest();
            
            positiveOutreach.Employed_or_Admitted_Healthcare__c = 'Yes';
            positiveOutreach.Employed_or_Admitted_Location_Type__c = 'ASSISTED_LIVING';
            update positiveOutreach;
        
        Test.stopTest();
        positiveOutreach = [SELECT Id, Contact.Is_In_Long_Term_Care_Facility__c FROM Case WHERE Id =: positiveOutreach.Id];
        
       // System.assertEquals(true, positiveOutreach.Contact.Is_In_Long_Term_Care_Facility__c);
    }
    
    static testMethod void testSyncHealthcareWorkerSetting() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Case Investigator'];
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser1@pih.org.invalidtest', Team__c='Team 1');
        insert user1;
        
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        
        Group g1 = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName='Positive_Outreach_Queue'];
        Id personAccountRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Account acc = new Account(FirstName='Robert', LastName='Browning', RecordTypeId=personAccountRtId);
        insert acc;

        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];

        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId, OwnerId=g1.Id, ContactId=con.Id);
        insert positiveOutreach;
        
        System.debug(positiveOutreach);
        
        Test.startTest();
        
            positiveOutreach.Is_Healthcare_Worker__c = 'Yes';
            update positiveOutreach;
        
        Test.stopTest();
        positiveOutreach = [SELECT Id, Contact.Is_Health_Care_Worker__c FROM Case WHERE Id =: positiveOutreach.Id];
        
       // System.assertEquals(true, positiveOutreach.Contact.Is_Health_Care_Worker__c);
    }


    /**
     * Test method for CaseTriggerHandler.ImplodeValues()
     * 
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-26
     */
    static testMethod void testImplodeValues()
    {
        //
        // Try with Contacts - OOB Field
        //
        List<Contact> recs1 = new List<Contact>();

        recs1.add(new Contact(LastName = 'A'));
        recs1.add(new Contact(LastName = 'B'));
        recs1.add(new Contact(LastName = 'C'));

        //System.assertEquals('A;B;C', CaseTriggerHandler.ImplodeValues(recs1, 'LastName'));

        
        //
        // Try with Cases - Custom Field
        //
        List<Case> recs2 = new List<Case>();

        recs2.add(new Case(Close_Reason__c = 'Aaa'));
        recs2.add(new Case(Close_Reason__c = 'Bbb'));
        recs2.add(new Case(Close_Reason__c = 'Ccc'));

        System.assertEquals('Aaa;Bbb;Ccc', CaseTriggerHandler.ImplodeValues(recs2, 'Close_Reason__c'));


        //
        // Try with Users -- using field references -- have to do a real query here. We should always have three Sys Admins, so query for those user records
        //
        List<User> recs3 = [SELECT Profile.Name FROM User WHERE Profile.Name = 'System Administrator' LIMIT 3];

        //System.assertEquals('System Administrator;System Administrator;System Administrator', CaseTriggerHandler.ImplodeValues(recs3, 'Profile.Name'));


        //
        // Confirm null values are handled correctly
        //
        List<Case> recs4 = new List<Case>();

        recs4.add(new Case(Close_Reason__c = 'Aaa'));
        recs4.add(new Case(Close_Reason__c = null));
        recs4.add(new Case(Close_Reason__c = 'Ccc'));

        //System.assertEquals('Aaa;;Ccc', CaseTriggerHandler.ImplodeValues(recs4, 'Close_Reason__c'));
    }
}