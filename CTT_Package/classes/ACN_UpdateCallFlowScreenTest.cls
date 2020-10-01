@isTest(SeeAllData = false)

public class ACN_UpdateCallFlowScreenTest{
    
    static testMethod void testUpdateDefaultAction(){
        /* Create test data */
        ACN_Call_Flow_Template__c cft1=new ACN_Call_Flow_Template__c(Name='test1');
        database.insert(cft1);
        ACN_Call_Flow_Screen__c cfs1=new ACN_Call_Flow_Screen__c(ACN_Call_Flow_Template__c=cft1.id,ACN_Stage_Sequence_No__c=1,ACN_Stage_Name__c='abcd1');
        database.insert(cfs1);
        ACN_Call_Flow_Screen__c cfs2=new ACN_Call_Flow_Screen__c(ACN_Call_Flow_Template__c=cft1.id,ACN_Stage_Sequence_No__c=2,ACN_Stage_Name__c='abcd');
        database.insert(cfs2);
        
        ACN_UpdateCallFlowScreen.updateDefaultAction(cft1.Id);
    }
}