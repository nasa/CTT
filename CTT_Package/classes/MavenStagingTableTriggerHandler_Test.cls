@IsTest
private class MavenStagingTableTriggerHandler_Test {
    private static testMethod void testMavenStagingTableTriggerHandler() {
        Maven_Staging_Table__c mst = new Maven_Staging_Table__c();

        mst.Maven_Contact_Id__c = '123456';
        mst.First_Name__c = 'Test';
        mst.Last_Name__c = 'Tester';
      	mst.Disease_Status__c = 'CONTACT';
            
        Test.startTest();

        insert mst;

        // Execute @futures
        Test.stopTest();

        List<Case> cases = [SELECT Id, AccountId, ContactId FROM Case WHERE Maven_Contact_Id__c = :mst.Maven_Contact_Id__c];
        System.assertNotEquals(null, cases);
        System.assertEquals(1, cases.size());
        System.assertNotEquals(null, cases[0].AccountId);
        System.assertNotEquals(null, cases[0].ContactId);
    }
    
    private static testMethod void testMavenStagingTableTriggerHandlerConfirmed() {
        Maven_Staging_Table__c mst = new Maven_Staging_Table__c();

        mst.Maven_Contact_Id__c = '123456';
        mst.First_Name__c = 'Test';
        mst.Last_Name__c = 'Tester';
      	mst.Disease_Status__c = 'CONFIRMED';
            
        Test.startTest();

        insert mst;

        // Execute @futures
        Test.stopTest();

        List<Case> cases = [SELECT Id, AccountId, ContactId FROM Case WHERE Maven_Contact_Id__c = :mst.Maven_Contact_Id__c];
        System.assertNotEquals(null, cases);
        System.assertEquals(1, cases.size());
        System.assertNotEquals(null, cases[0].AccountId);
        System.assertNotEquals(null, cases[0].ContactId);
    }
}