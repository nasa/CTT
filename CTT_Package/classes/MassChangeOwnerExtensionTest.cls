@isTest
public class MassChangeOwnerExtensionTest {
    @testSetup
    private static void setup(){
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        Id rtId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Contact_Outreach').getRecordTypeId();
        
        Group g1 = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName='Positive_Outreach_Queue'];
        
        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId, OwnerId=g1.Id);
        
        insert positiveOutreach;
    }

    @isTest
    private static void Test_MassChangeOwner_Extension(){
        Test.startTest();  
        List<Case> cas = [SELECT id FROM Case];
        ApexPages.StandardSetController standController = new ApexPages.StandardSetController(cas);
        MassChangeOwnerExtension extensionClass = new MassChangeOwnerExtension(standController);
        Test.stopTest();
        System.assertEquals(false,extensionClass.displayChangeOwner);
        standController.setSelected(cas);
        MassChangeOwnerExtension secondClass = new MassChangeOwnerExtension(standController);       
        System.assertNotEquals(null,secondClass.selectedCases);
        System.assertEquals(null,secondClass.url);
    }   
    
    @isTest
    private static void TestBackToList(){
        Test.startTest();  
        List<Case> cas = [SELECT id FROM Case];
        ApexPages.StandardSetController standController = new ApexPages.StandardSetController(cas);
        MassChangeOwnerExtension extensionClass = new MassChangeOwnerExtension(standController);
		PageReference testRef = extensionClass.BackToList();
        Test.stopTest();
        system.assertEquals(null, testRef);
    }
}