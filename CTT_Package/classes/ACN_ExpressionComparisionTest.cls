@isTest
private class ACN_ExpressionComparisionTest {
    
    static testMethod void testgetNewTemplateDetails(){
        /* Create test data */
        ACN_Call_Flow_Template__c cft=new ACN_Call_Flow_Template__c(Name='test');
        database.insert(cft);
        ACN_Call_Flow_Screen__c cfs=new ACN_Call_Flow_Screen__c(ACN_Call_Flow_Template__c=cft.id);
        database.insert(cfs);
        ACN_Call_Flow_Screen__c cfsrec=[select id,ACN_Screen_Number__c from ACN_Call_Flow_Screen__c where id=:cfs.id LIMIT 1];
        ACN_ExpressionComparision.getNewTemplateDetails(cfsrec.ACN_Screen_Number__c);
        System.assert(cft.id!= null);
    }
    
    static testMethod void testgetProgressPathDetails(){
        /* Create test data */
        ACN_Call_Flow_Template__c cft1=new ACN_Call_Flow_Template__c(Name='test1');
        database.insert(cft1);
        ACN_Call_Flow_Screen__c cfs1=new ACN_Call_Flow_Screen__c(ACN_Call_Flow_Template__c=cft1.id,ACN_Stage_Sequence_No__c=2,ACN_Stage_Name__c='abcd');
        database.insert(cfs1);
        ACN_Question_Repository__c qrep=new ACN_Question_Repository__c(Name='repository');
        database.insert(qrep);
        ACN_Screen_Data_Elements__c sde1=new ACN_Screen_Data_Elements__c(ACN_Screen__c=cfs1.id,ACN_Question__c=qrep.id);
        database.insert(sde1);
        String tempid=cft1.id;
        ACN_ExpressionComparision.getProgressPathDetails(tempid);
        System.assert(cft1.id!= null);
        
    }
    static testMethod void testgetSaveQuestion(){
        /* Create test data */
        ACN_Call_Flow_Template__c cft2=new ACN_Call_Flow_Template__c(Name='test1');
        insert cft2;
        ACN_Call_Flow_Screen__c cfs2=new ACN_Call_Flow_Screen__c(ACN_Call_Flow_Template__c=cft2.id,ACN_Stage_Sequence_No__c=1,ACN_Stage_Name__c='abcd');
        insert cfs2;
        ACN_Question_Repository__c qrep1=new ACN_Question_Repository__c(Name='Ques1');
        insert qrep1;
        ACN_Screen_Data_Elements__c sde2=new ACN_Screen_Data_Elements__c(ACN_Screen__c=cfs2.Id,ACN_Question__c=qrep1.Id);
        insert sde2;
        ACN_Screen_Data_Elements__c sde2srec=[select id, ACN_Question_Identifier__c from ACN_Screen_Data_Elements__c where id=:sde2.id LIMIT 1];
        Account acc1=new Account(Name='test2');
        insert acc1;
        // System.assert(cft2.id!= null);
        
        List<ACN_QuestionniareContainerCtrl.questionWrapper> listques = new List<ACN_QuestionniareContainerCtrl.questionWrapper>();
        ACN_QuestionniareContainerCtrl.questionWrapper ques = new ACN_QuestionniareContainerCtrl.questionWrapper(sde2srec, 'test','', cft2.Id, true);
        listques.add(ques);
        String jsonString = JSON.serialize(listques);
        List<String> quesResMap=new List<String>(); 
        quesResMap.add(sde2srec.ACN_Question_Identifier__c);
        String paramString='location=\'ACN_Care_Team__c\';age=80;country=India';
        ACN_ExpressionComparision.getAdditionalParams(cft2.Id, acc1.id, paramString);
        paramString='location=\'ACN_Care_Team\';age=80;country=India';
        ACN_ExpressionComparision.getAdditionalParams(cft2.Id, acc1.id, paramString);
        ACN_ExpressionComparision.SaveQuestion(jsonString, quesResMap,'Case',acc1.id,cft2.Id);
        ACN_ExpressionComparision.SaveQuestion(null, quesResMap,'Host',acc1.id,cft2.Id);

    }
}