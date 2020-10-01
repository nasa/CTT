/*test class for ACN_TemplateSelectionCtrl
 * created by : Ashish 
*/

@isTest
public class ACN_TemplateSelectionCtrlTest
{
    @isTest static void testTemplates()
    {
        ACN_Call_Flow_Template__c temp1 = new ACN_Call_Flow_Template__c();
        temp1.Name = 't1';
        database.insert(temp1);
        
        Test.startTest();
        List<ACN_Call_Flow_Template__c> getTemplates = ACN_TemplateSelectionCtrl.getTemplates();
        System.assertEquals(getTemplates, null);
        temp1.ACN_Status__c = 'Active';
        database.update(temp1);
        getTemplates = ACN_TemplateSelectionCtrl.getTemplates();
        System.assertEquals(getTemplates.size(), 1);
        ACN_TemplateSelectionCtrl.getRecordDetails(temp1.Id);
        ACN_TemplateSelectionCtrl.getRecordDetails(null);
        Test.stopTest();
    }
}