@isTest(SeeAllData = false)
public class AccountBeforeUpdateTest {
  static testMethod void testPositiveCaseWithContacts(){
        Id posOutreachRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Positive_Outreach').getRecordTypeId();        
        Id contOutreachRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Contact_Outreach').getRecordTypeId();        
        Id personAccountRtId    = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account positiveAcct = new Account(FirstName='John', LastName='JohnsonT1', RecordTypeId=personAccountRtId, Home_Location__pc = 'Location1');
        insert positiveAcct;
        Case positiveOutreach = new Case(Status='Awaiting Outreach', Origin='Phone', RecordTypeId=posOutreachRecordTypeId, ContactId=positiveAcct.PersonContactId, AccountId=positiveAcct.Id, Onsite_Exposure_Location__c = 'Location1');
        insert positiveOutreach;
        Account contactAcct = new Account(FirstName='Marshall', LastName='SmithContact', RecordTypeId=personAccountRtId);
        insert contactAcct;
        Case contactOutreach = new Case(Status='Awaiting Outreach', Origin='Phone', RecordTypeId=contOutreachRecordTypeId, ParentId=positiveOutreach.Id,ContactId=contactAcct.PersonContactId, AccountId = contactAcct.Id, Onsite_Exposure_Location__c = 'Location1' );
        insert contactOutreach;
       
        Test.startTest();
        contactAcct.Home_Location__pc = 'Location1';
        update contactAcct;
        Test.stopTest();
        String posClinicGroupID = ContactChangeUtility.getContactClinincGroupID(positiveAcct.Home_Location__pc);
        List<CaseShare> caseShareLs ;
        caseShareLs = [select Id, CaseId, UserOrGroupId, UserOrGroup.Name FROM CaseShare  Where CaseId =:positiveOutreach.Id AND UserOrGroupId = :posClinicGroupID Limit 1];        
       // System.assertEquals(true, caseShareLs.Size()>0);
       List<Case> caselist = new List<Case>();
      caselist.add(contactOutreach);
      ContactClinicChangeWrapper cccw = new ContactClinicChangeWrapper();
      cccw.cntct = contactAcct;
     // cccw.contactCases = caselist;
    // ContactClinicChangeHandler ccch = new ContactClinicChangeHandler();
      ContactClinicChangeHandler.InitPositiveCaseShare(cccw, contactOutreach);
    }
}