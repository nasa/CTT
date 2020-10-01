/*
@class - TestClassScheduler
@Description - Run the test classes associated with the classes modified at end of everyday
*/

global class TestClassScheduler implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
    
    public Map<String,String> userMap = new Map<String,String>();
    
    //Scheduler
    global void execute(SchedulableContext sc) {
        TestClassScheduler sch = new TestClassScheduler();
        DataBase.executeBatch(sch);
    }
    
    //Start
    global DataBase.QueryLocator start(DataBase.BatchableContext BC){
        String query = 'Select id,Name,LastModifiedBy.Name from ApexClass where LastModifiedDate=TODAY';
        return DataBase.getQueryLocator(query);
    }
    
    //execute
    global void execute(DataBase.BatchableContext BC,List<sObject> scope){
        List<ApexClass> apexList = (List<ApexClass>)scope;
        Set<String> apexClassName = new Set<String>();
        Set<String> testClassList = new Set<String>();
        ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
        List<Component__c> cmpList = new List<Component__c>();
        
        //Iterate through list to get apex class name
        for(ApexClass apxObj : apexList) {
            apexClassName.add(apxObj.Name);
        }
        
        //Get Component records 
        if(apexClassName.size()>0){
            cmpList = [Select id,Test_Class_Name__c,LastModifiedDate,Component_API_Name__c 
                              from Component__c where Component_Type__c='Apex Class' 
                              AND Component_API_Name__c IN :apexClassName];
        }
        
        //Iterate through component record and apex list to find who used synchofy or not.
        //Run Test class
        for(ApexClass apxCls : apexList) {
            Boolean isSynchofyUsed = false;
            
            for(Component__c cmp : cmpList) {
                
                system.debug('apxCls.Name>>>'+apxCls.Name);
                system.debug('cmp.Component_API_Name__c>>>>'+cmp.Component_API_Name__c);
                system.debug('cmp.LastModifiedDate>>>>>>>>>'+cmp.LastModifiedDate.Date());
                system.debug('SYSTEM.TODAY()>>>>>>>'+SYSTEM.TODAY());
                
                if((apxCls.Name == cmp.Component_API_Name__c) && (cmp.LastModifiedDate.Date() == SYSTEM.TODAY())) {
                    isSynchofyUsed = true;
                    testClassList.add(cmp.Test_Class_Name__c);
                }
            }
            
            if(!isSynchofyUsed) {
                userMap.put(apxCls.Name,apxCls.LastModifiedBy.Name);
            }
        }
        
        if(testClassList.size()>0) {
            for(ApexClass testClass : [SELECT Id,Name FROM ApexClass where Name=:testClassList]) {
                queueItems.add(new ApexTestQueueItem(ApexClassId=testClass.Id));
            }
        }
        
        insert queueItems;
    }
    
    global void finish(DataBase.BatchableContext BC){
        //Send mail
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'soumen.jana.cemk@gmail.com'};
        mail.setReplyTo('soumen.jana@accenture.com');
        mail.setSenderDisplayName('Synchofy Support');
        mail.setSubject('Synchofy Status');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setToAddresses(toAddresses);
        String body = '<table border="1"><tr><th>Class Name</th><th>Last Modified By</th></tr>';
        
        for(String str : userMap.keySet()) {
            body = body+'<tr><td>'+str+'</td><td>'+userMap.get(str)+'</td></tr>';
        }
        
        body = body+'</table>';
        
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}