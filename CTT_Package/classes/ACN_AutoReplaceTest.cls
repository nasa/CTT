@isTest(SeeAllData=true)
private class ACN_AutoReplaceTest {
    public static testMethod void testAutoReplaceTrigger() {
        ACN_Call_Flow_Template__c newTemplate = new ACN_Call_Flow_Template__c();
        newTemplate.Name = 'new Sample Template';
        newTemplate.ACN_Status__c = 'Inactive';
        insert newTemplate;
        
        ACN_Call_Flow_Screen__c newScreen = new ACN_Call_Flow_Screen__c();
        newScreen.Name = 'new Sample Screen';
        newScreen.ACN_Screen_Logic__c = '{(QI-000001 = Yes && QI-000004 = No)=:SN-000001}{(QI-000001 = Yes && QI-000004 = No)=:SN-000003}';
        newScreen.ACN_Call_Flow_Template__c = newTemplate.Id; // 'a1y2a000000cD4KAAU';
        insert newScreen;
        System.debug('NewID:::: '+[SELECT Id, Name, ACN_Screen_Logic__c from ACN_Call_Flow_Screen__c where Id =:newScreen.Id]);
        
        ACN_Screen_Data_Elements__c newDataEle = new ACN_Screen_Data_Elements__c();
        newDataEle.ACN_Question_Logic__c = '{(QI-000001 = Yes && QI-000004 = No)=:QI-000001}{(QI-000001 = Yes && QI-000004 = No)=:QI-000001}';
        newDataEle.ACN_Screen__c = newScreen.Id; // 'a1z2a000000Key1AAC';
        insert newDataEle;
        System.debug('NewID:::: '+[SELECT Id, Name, ACN_Question_Logic__c from ACN_Screen_Data_Elements__c where Id =:newDataEle.Id]);
    }
}