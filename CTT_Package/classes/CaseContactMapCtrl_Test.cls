@isTest(SeeAllData = false)
public class CaseContactMapCtrl_Test{

    static testMethod void testGetAddressDetailsAccount() {
        
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        
        Account acc = new Account(Name='Test Public Library', BillingStreet='123 Billing Street', BillingCity='Boston',
                                    BillingState = 'Massachusetts');
        insert acc;
        
        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId, AccountId=acc.Id);
        insert positiveOutreach;
        
        List<CaseContactMapCtrl.mapMarkerWrapper> mmWrapper;
        
        Test.startTest();
        
            mmWrapper = CaseContactMapCtrl.getAdressDetails(String.valueOf(positiveOutreach.Id));
        
        Test.stopTest();
        
        System.assert(mmWrapper!=null);
        System.assertEquals('123 Billing Street', mmWrapper[0].location.Street);
        System.assertEquals('Boston', mmWrapper[0].location.City);
        System.assertEquals('Massachusetts', mmWrapper[0].location.State);
        
    }
    
    static testMethod void testGetAddressDetailsContact() {
        
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();
        
        Account acc = new Account(Name='Test Public Library', BillingStreet='123 Billing Street', BillingCity='Boston',
                                    BillingState = 'Massachusetts');
        insert acc;
        
        Contact con = new Contact(FirstName='Bill', LastName='Manning', MailingStreet='456 Billing Street', MailingCity='Boston',
                                    MailingState='Massachusetts', AccountId=acc.Id);
        insert con;
        
        Case positiveOutreach = new Case(Status='New', Origin='Phone', RecordTypeId=rtId, ContactId=con.Id);
        insert positiveOutreach;
        
        System.debug(positiveOutreach);
        
        List<CaseContactMapCtrl.mapMarkerWrapper> mmWrapper;
        
        Test.startTest();
        
            mmWrapper = CaseContactMapCtrl.getAdressDetails(String.valueOf(positiveOutreach.Id));
        
        Test.stopTest();
        
        System.assert(mmWrapper!=null);
        System.assertEquals('456 Billing Street', mmWrapper[0].location.Street);
        System.assertEquals('Boston', mmWrapper[0].location.City);
        System.assertEquals('Massachusetts', mmWrapper[0].location.State);
    }
}