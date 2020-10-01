@isTest
private class ACN_QuestionniareContainerCtrlTest{
    static testMethod void questionniareContainerCtrl()
    { 
        /*Create Test Data*/
        
        ACN_Call_Flow_Template__c cft = new ACN_Call_Flow_Template__c(Name='test');
        database.insert(cft);
        ACN_Call_Flow_Screen__c cfs = new ACN_Call_Flow_Screen__c(ACN_Call_Flow_Template__c=cft.id);
        database.insert(cfs);
        ACN_Screen_Data_Elements__c sde = new ACN_Screen_Data_Elements__c(ACN_Screen__c=cfs.id);
        database.insert(sde);
        String tid = cft.id;
        system.assert(tid!=null);
        ACN_QuestionniareContainerCtrl.getQuestionDetails(tid);
        ACN_QuestionniareContainerCtrl.getQuestionDetails(null);
        ACN_QuestionniareContainerCtrl.getProgressPathDetails(tid);
        Account acc = new Account(Name='Sample Acc1',ACN_Care_Team__c=true);
        insert acc;
        String paramString='location=\'ACN_Care_Team__c\';age=80;country=India';
        List<ACN_QuestionniareContainerCtrl.extraParameterWrapper> extraParamMap = ACN_QuestionniareContainerCtrl.getAdditionalParams(tid, acc.Id, paramString);
        paramString='location=\'ACN_Care_Team\';age=80;country=India';
        ACN_QuestionniareContainerCtrl.getAdditionalParams(tid, acc.Id, paramString);
        //system.assert(extraParamMap!=null);
        
    }
    
}