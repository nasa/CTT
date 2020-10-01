public without sharing class ACN_QuestionniareContainerCtrl {
    
    public without sharing class questionWrapper{
        @AuraEnabled
        public ACN_Screen_Data_Elements__c eachQuesDetails{get;set;}
        @AuraEnabled
        public string allResponseDetails{get;set;}
        @AuraEnabled
        public string defaultAnswer{get;set;}
        @AuraEnabled
        public string callFlowTemplateId{get;set;}
        @AuraEnabled
        public Boolean isDefaultQuestion{get;set;}
        /* @AuraEnabled
        public List<questionWrapper> questionWrapper{get;set;}
        @AuraEnabled
        public List<extraParameterWrapper> extraParameterWrapper{get;set;} */
        
        public questionWrapper(ACN_Screen_Data_Elements__c eachQuesDetails, String allResponseDetails, String defaultAnswer, String callFlowTemplateId, Boolean isDefaultQuestion) {
            this.eachQuesDetails = eachQuesDetails;
            this.allResponseDetails = allResponseDetails;
            this.defaultAnswer = defaultAnswer;
            this.callFlowTemplateId = callFlowTemplateId;
            this.isDefaultQuestion = isDefaultQuestion;
        }
        /* public questionWrapper(List<questionWrapper> questionWrapper, List<extraParameterWrapper> extraParameterWrapper){
            this.questionWrapper = questionWrapper;
            this.extraParameterWrapper = extraParameterWrapper;
        } */
    }
    public without sharing class extraParameterWrapper{
        @AuraEnabled
        public String key{get;set;}
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public String templateId{get;set;}
        
        public extraParameterWrapper(String key, String value, String templateId) {
            this.key = key;
            this.value = value;
            this.templateId = templateId;
        }
    }
    /* public without sharing class QRwrapper{
        @AuraEnabled
        public List<questionWrapper> questionWrapper{get;set;}
        @AuraEnabled
        public List<extraParameterWrapper> extraParameterWrapper{get;set;}
        
        public QRwrapper(List<questionWrapper> questionWrapper, List<extraParameterWrapper> extraParameterWrapper){
            this.questionWrapper = questionWrapper;
            this.extraParameterWrapper = extraParameterWrapper;
        }
    } */
    
    @AuraEnabled
    public static List<questionWrapper> getQuestionDetails(String templateId){
        // templateId = 'a1y2a000000cD4KAAU';
        List<questionWrapper> quesWrapper = new List<questionWrapper>();
        try{
            for(ACN_Screen_Data_Elements__c eachData : [Select Id, Name, ACN_Question_Identifier__c, ACN_Display_Order__c, 
                                                        ACN_Question_Logic__c, ACN_Default_Question__c, ACN_Default_Answer__c,
                                                        ACN_Screen__r.ACN_Screen_Logic__c,ACN_Screen__r.ACN_Screen_Number__c,                                                         
                                                        ACN_Input_Questions__c,ACN_Screen__r.ACN_Default_Action_Screen__c, 
                                                        ACN_Screen__r.ACN_isStartScreen__c, ACN_Screen__r.ACN_isEndScreen__c, ACN_Screen__r.Hide_Next__c,
                                                        ACN_Screen__r.ACN_Default_Questions__c, ACN_Screen__r.ACN_Call_Flow_Template__r.Name,
                                                        ACN_Question__r.Name,ACN_Question__r.ACN_Type__c, ACN_Question__r.ACN_Options__c, 
                                                        ACN_Question__r.ACN_Question_Description__c,
                                                        ACN_Screen__r.ACN_hasBranching__c,ACN_Screen__r.ACN_Stage_Sequence_No__c,
                                                        ACN_Screen__r.ACN_Layout_Column__c,ACN_Options_Layout__c,ACN_Screen__r.ACN_Show_Serial_No__c,
                                                        ACN_Screen__r.ACN_Stage_Name__c,ACN_Question__r.ACN_Compound_Screen__c,ACN_Screen__r.ACN_Call_Flow_Template__r.ACN_Extra_Parameters__c
                                                        FROM ACN_Screen_Data_Elements__c
                                                        WHERE ACN_Screen__r.ACN_Call_Flow_Template__c =: templateId
                                                        Order By ACN_Display_Order__c, ACN_Screen__r.ACN_Stage_Sequence_No__c 
                                                        ASC])
            {
                System.debug('eachData.ACN_Default_Answer__c:::: '+eachData.ACN_Default_Answer__c);
                quesWrapper.add(new questionWrapper(eachData, '', eachData.ACN_Default_Answer__c != null ? eachData.ACN_Default_Answer__c : '', templateId, eachData.ACN_Default_Question__c));
            }
            
            System.debug('quesWrapper:::: '+quesWrapper.size());
            
            return quesWrapper;
        }
        catch(Exception e){
            return null;
        }
    }
    
    
    /* @AuraEnabled
public static questionWrapper getQuestionDetails(String templateId){
// templateId = 'a1y2a000000cD4KAAU';
Boolean hasExtraParams = false;
List<questionWrapper> quesWrapper = new List<questionWrapper>();
try{
for(ACN_Screen_Data_Elements__c eachData : [Select Id, Name, ACN_Question_Identifier__c, ACN_Display_Order__c, 
ACN_Question_Logic__c, ACN_Default_Question__c, 
ACN_Screen__r.ACN_Screen_Logic__c,ACN_Screen__r.ACN_Screen_Number__c,                                                         
ACN_Input_Questions__c,ACN_Screen__r.ACN_Default_Action_Screen__c, 
ACN_Screen__r.ACN_isStartScreen__c, ACN_Screen__r.ACN_isEndScreen__c, ACN_Screen__r.Hide_Next__c,
ACN_Screen__r.ACN_Default_Questions__c, ACN_Screen__r.ACN_Call_Flow_Template__r.Name,
ACN_Question__r.Name,ACN_Question__r.ACN_Type__c, ACN_Question__r.ACN_Options__c, 
ACN_Question__r.ACN_Question_Description__c,
ACN_Screen__r.ACN_hasBranching__c,ACN_Screen__r.ACN_Stage_Sequence_No__c,
ACN_Screen__r.ACN_Layout_Column__c,ACN_Options_Layout__c,ACN_Screen__r.ACN_Show_Serial_No__c,
ACN_Screen__r.ACN_Stage_Name__c,ACN_Question__r.ACN_Compound_Screen__c,ACN_Screen__r.ACN_Call_Flow_Template__r.ACN_Extra_Parameters__c
FROM ACN_Screen_Data_Elements__c
WHERE ACN_Screen__r.ACN_Call_Flow_Template__c =: templateId
Order By ACN_Display_Order__c, ACN_Screen__r.ACN_Stage_Sequence_No__c 
ASC])
{
System.debug('eachData:::: '+eachData.ACN_Screen__r.ACN_Call_Flow_Template__r.ACN_Extra_Parameters__c);
quesWrapper.add(new questionWrapper(eachData, '', templateId, eachData.ACN_Default_Question__c));
if(eachData.ACN_Screen__r.ACN_Call_Flow_Template__r.ACN_Extra_Parameters__c != null){
hasExtraParams = true;
}
}

System.debug('quesWrapper:::: '+quesWrapper.size()+' :::: '+hasExtraParams);

List<extraParameterWrapper> extraParams = new List<extraParameterWrapper>();
if(hasExtraParams){
extraParams= getAdditionalParams(templateId);
}
questionWrapper ques_extraParams = new questionWrapper(quesWrapper,extraParams);

// ques_extraParams(quesWrapper,extraParams);

return ques_extraParams; // quesWrapper;
}
catch(Exception e){
return null;
}
} */
    @AuraEnabled
    public static List<extraParameterWrapper> getAdditionalParams(String templateId, String recordId, String paramString){
        try{
            // paramString='location=\'HealthCloudGA__Age__pc\';age=80;param=india';
            // templateId='temp1';
            String queryString = 'SELECT Id,';
            // recordId = '0012a000004UGyYAAW'; // a1y2a000000cD4KAAU // a1z2a000000KexwAAC
            List<ACN_QuestionniareContainerCtrl.extraParameterWrapper> extraParams = new List<ACN_QuestionniareContainerCtrl.extraParameterWrapper>();
            String[] opertions =  paramString.split(';');
            System.debug('opertions:::: '+opertions);
            for(String ops : opertions){
                String[] operands = ops.split('=');
                queryString += operands[1].startsWith('\'') ? operands[1].removeEnd('\'').removeStart('\'')+',' : '';
                extraParams.add(new ACN_QuestionniareContainerCtrl.extraParameterWrapper(operands[0],operands[1],templateId));
            }
            System.debug('queryString:::: '+queryString);
            System.debug('extraParams1:::: '+extraParams);
            
            String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            
            queryString = queryString.removeEnd(',') + ' FROM ' + sObjName +' WHERE Id =:recordId';
            
            System.debug('queryString:::: '+queryString);
            
            sObject rec = Database.query(queryString);
            
            for(ACN_QuestionniareContainerCtrl.extraParameterWrapper param : extraParams){
                if(param.value.startsWith('\'')){
                    System.debug(rec.get(param.value.removeEnd('\'').removeStart('\'')));
                    param.value = String.valueOf(rec.get(param.value.removeEnd('\'').removeStart('\'')));
                }
            }
            
            System.debug('extraParams2:::: '+extraParams);
            
            return extraParams; // newAttributes;
        }
        catch(Exception e)
        {
            return null;
        }
    }
    
    @AuraEnabled
    public static Map<Integer, String> getProgressPathDetails(String templateId) {
        
        // templateId = 'a1y2a000000cD4KAAU';
        Map<Integer, String> mapProgressPath = new Map<Integer, String>();
        try{
            /* list<ACN_Screen_Data_Elements__c> listAllQues = new list<ACN_Screen_Data_Elements__c>([Select ACN_Screen__r.ACN_Stage_Sequence_No__c, ACN_Screen__r.ACN_Stage_Name__c
                                                                                                   from ACN_Screen_Data_Elements__c 
                                                                                                   where ACN_Screen__r.ACN_Call_Flow_Template__c =: templateId Limit 50000]);
            */
            for(ACN_Screen_Data_Elements__c each : [SELECT ACN_Screen__r.ACN_Stage_Sequence_No__c, ACN_Screen__r.ACN_Stage_Name__c
                                                    FROM ACN_Screen_Data_Elements__c 
                                                    WHERE ACN_Screen__r.ACN_Call_Flow_Template__c =: templateId]) {
                                                        mapProgressPath.put((Integer)each.ACN_Screen__r.ACN_Stage_Sequence_No__c, each.ACN_Screen__r.ACN_Stage_Name__c);
                                                    }
        }
        catch(Exception e)
        {
            return null;
        }
        //System.debug('MAP PROGRESS PATH:::: '+mapProgressPath);
        return mapProgressPath;
    }
    
}