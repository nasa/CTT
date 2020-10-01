@isTest
public with sharing class TriggerFrameworkTest {
    
    public static Profile getProfileInfo(String profileName) {
        Profile profileInfo = [SELECT Id, Name FROM Profile WHERE Name=:profileName];
        return profileInfo;
    }
    
    public static testmethod void testConfigEnabledBeforeInsert() {        
		insert new Account(Name='foobar');
    }
    
    public static testmethod void testConfigEnabledBeforeUpdate() {
        Account newAccount = new Account(Name='foobar');
        insert newAccount;
        newAccount.Name = 'foo';
        update newAccount;
    }	
    
    public static testmethod void testConfigEnabledBeforeDelete() {        
        Account newAccount = new Account(Name='foobar');
        insert newAccount;
        delete newAccount;
    }       
    
    public static testmethod void testConfigEnabledAfterUnDelete() {        
        Account newAccount = new Account(Name='foobar');
        insert newAccount;
        delete newAccount;
        undelete newAccount;
    }
    
    @isTest
    public static void testGetRecursionDepth() {
        Test.startTest();
        TriggerFramework.Context obj = new TriggerFramework.Context(new List<Account>(), new List<Account>(), new Map<Id, Account>(), 
                                                                    new Map<Id, Account>(), true, false, false, true, false, true, false);
        obj.enterObject();
        obj.getRecursionDepth();
        obj.beginTrans();
        obj.rollbackTrans();
        Test.stopTest();
    }
    
    
     @isTest
    public static void testInsertExposedContactReview() {
        Test.startTest();
        Exposed_Contact_Review__c obj = new Exposed_Contact_Review__c ();
        obj.last_name__c = 'testLastName';
            insert obj;
        Test.stopTest();
    }
    
    
}