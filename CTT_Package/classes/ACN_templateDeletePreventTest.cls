@isTest
public class ACN_templateDeletePreventTest {
    
    private static testmethod void templateDelPreventTest(){
        List<ACN_Call_Flow_Template__c> listOfTemplate = new List<ACN_Call_Flow_Template__c>();
        
        ACN_Call_Flow_Template__c tmp1 = new ACN_Call_Flow_Template__c();        
        tmp1.Name = 'temp1';
        tmp1.ACN_Status__c = 'Active';
        listOfTemplate.add(tmp1);
        
        ACN_Call_Flow_Template__c tmp2 = new ACN_Call_Flow_Template__c();
        tmp2.Name = 'temp2';
        tmp2.ACN_Status__c = 'Active';
        listOfTemplate.add(tmp2); 
        
        insert listOfTemplate;        
        
        ACN_Call_Flow_Screen__c screenData = new ACN_Call_Flow_Screen__c();
        screenData.ACN_Call_Flow_Template__c = tmp1.Id;
        screenData.Name = 'sc1'; 
        insert screenData;
        
        try{
            Delete listOfTemplate;
            //Delete tmp2;
        }
        catch(Exception ee)
        {}
    }
}