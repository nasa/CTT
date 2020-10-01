public with sharing class ACN_TemplateSelectionCtrl {
    @AuraEnabled
    public static List<ACN_Call_Flow_Template__c> getTemplates(){
        try{
            List<ACN_Call_Flow_Template__c> flowTemp = [Select Id, Name, ACN_Description__c, ACN_Status__c, ACN_Type__c, ACN_Template_Sequence_No__c from ACN_Call_Flow_Template__c where ACN_Status__c = 'Active' order by ACN_Template_Sequence_No__c ASC LIMIT 1000];
            system.debug('flowTemp**' + flowTemp);
            if(flowTemp.size() > 0){
                return flowTemp;
            }
        }
        catch (Exception e){
            System.debug('Exception Occured:::: '+e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static sObject getRecordDetails(String recordId) {
        try{
            String sobjectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            SObject record = Database.query('SELECT Id, Name FROM ' + sobjectName + ' WHERE Id = :recordId LIMIT 1');
            if(record != null){
                return record;
            }
        }
        catch (Exception e){
            System.debug('Exception Occured:::: '+e.getMessage());
        }
        return null;
    }
    
    /* @AuraEnabled
    public static List<ACN_Call_Flow_Template__c> getTemplateByFilter(String gender, String age){
        try{
            List<ACN_Call_Flow_Template__c> flowTemp;
            Set<String> templateIdSet = new Set<String>();
            System.debug('Age : ' + age);
            System.debug('gender : ' + gender);
            List<String> ageList = age.split(' ');
            if(!ageList.isEmpty()){
                String ageVal = ageList.get(0);
                System.debug('ageVal : ' + ageVal);
                Integer ageNum = Integer.valueOf(ageVal);
                List<Template_Selection_Setting__c> templateCustomSettingList = [Select TemplateId__c from Template_Selection_Setting__c 
                                                                                 where Gender__c = :gender AND AgeNumLowerLimit__c <= :ageNum AND AgeNumUpperLimit__c >= :ageNum LIMIT 100];
                System.debug('templateCustomSettingList**' + templateCustomSettingList);	
                if(!templateCustomSettingList.isEmpty()){
                    for(Template_Selection_Setting__c setting : templateCustomSettingList){
                        templateIdSet.add(setting.TemplateId__c);
                    }
                    System.debug('templateIdSet : ' + templateIdSet);
                }
                flowTemp = [Select Id, Name, ACN_Description__c, ACN_Status__c, ACN_Type__c, ACN_Template_Sequence_No__c from ACN_Call_Flow_Template__c where id = :templateIdSet order by ACN_Template_Sequence_No__c ASC LIMIT 100];
                System.debug('flowTemp**' + flowTemp);	
                
                
            }
            return flowTemp;
        }
        catch (Exception e){
            System.debug('Exception Occured:::: '+e.getMessage());
        }
        return null;
    } */
}