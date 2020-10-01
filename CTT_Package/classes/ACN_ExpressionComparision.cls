// this is Controller class for ACN_QuestionnaireContainer component
public without sharing class ACN_ExpressionComparision { 
    // returns list of questions when there is change in template
    @AuraEnabled
    public static List<ACN_QuestionniareContainerCtrl.questionWrapper> getNewTemplateDetails(String screenNo) {
        try{
            List<ACN_Call_Flow_Screen__c> getNewTemplateId = [SELECT Id, ACN_Call_Flow_Template__c from 
                                                              ACN_Call_Flow_Screen__c 
                                                              where ACN_Screen_Number__c =: screenNo LIMIT 1];
            return ACN_QuestionniareContainerCtrl.getQuestionDetails(getNewTemplateId[0].ACN_Call_Flow_Template__c);
        }
        catch(exception e){
            // System.debug('Exception Occured:: '+e.getMessage());
            return null;
        }
    }
    
    // returns list of questions when there is change in template
    @AuraEnabled
    public static List<ACN_QuestionniareContainerCtrl.extraParameterWrapper> getAdditionalParams(String templateId, String recordId, String paramString){
        /* List<ACN_QuestionniareContainerCtrl.extraParameterWrapper> newAttributes= new List<ACN_QuestionniareContainerCtrl.extraParameterWrapper>();
        newAttributes.add(new ACN_QuestionniareContainerCtrl.extraParameterWrapper('direction','north',templateId));
        newAttributes.add(new ACN_QuestionniareContainerCtrl.extraParameterWrapper('home','3bhk duplex',templateId));
        newAttributes.add(new ACN_QuestionniareContainerCtrl.extraParameterWrapper('vehicle','car;bike',templateId));
        
        System.debug('newAttributes:::: '+newAttributes); */
        try{
        return ACN_QuestionniareContainerCtrl.getAdditionalParams(templateId, recordId, paramString);
        }
        catch(exception e){
            // System.debug('Exception Occured:: '+e.getMessage());
        }
        return null;
    } 
    
    // returns new set of progress paths when template changes.
    @AuraEnabled
    public static Map<Integer, String> getProgressPathDetails(String templateId) {
        try{
            // templateId = 'a1y2a000000cD4KAAU';
            System.debug('templateId:::: '+templateId);
            Map<Integer, String> mapProgressPath = new Map<Integer, String>();
            
            for(ACN_Screen_Data_Elements__c each : [SELECT ACN_Screen__r.ACN_Stage_Sequence_No__c, ACN_Screen__r.ACN_Stage_Name__c FROM ACN_Screen_Data_Elements__c 
                                                    WHERE ACN_Screen__r.ACN_Call_Flow_Template__c =: templateId]) {
                                                        mapProgressPath.put((Integer)each.ACN_Screen__r.ACN_Stage_Sequence_No__c, each.ACN_Screen__r.ACN_Stage_Name__c);
                                                    }
            System.debug('MAP PROGRESS PATH:::: '+mapProgressPath);
            return mapProgressPath;
        }
        catch(exception e){
            // System.debug('Exception Occured:: '+e.getMessage());
            return null;
        }
    }
    // save the ques and the response
    @AuraEnabled
    public static void SaveQuestion(string allQuestionMap , List<String> QuesRespMap, String associationTo, String recordId, String templateId){
        // system.debug('allQuestionMap@@: ' + allQuestionMap);
        // system.debug('QuesRespMap@@: '  + QuesRespMap);
        try {
            List<ACN_QuestionniareContainerCtrl.questionWrapper> wrapperResponse = (List<ACN_QuestionniareContainerCtrl.questionWrapper>)JSON.deserialize(allQuestionMap, List<ACN_QuestionniareContainerCtrl.questionWrapper>.class);
            List<ACN_Question_Response__c> allResponses = new List<ACN_Question_Response__c>();
            ACN_Call_Flow_Conducted__c newFlowConducted = new ACN_Call_Flow_Conducted__c();
            newFlowConducted.ACN_Call_Flow_Template__c = templateId;
            Recordtype caseRT = [select Id, developerName, sobjecttype from Recordtype where developerName='CarePlan' AND SobjectType='Case' LIMIT 1][0];
            Case newCase = new Case(Risk_Category__c='High Risk',Origin='Web-Flow',Priority='High',Subject='COVID-19 Assessment',recordtypeId=caseRT.Id);
/*
            if(associationTo == 'Case'){
                insert newCase;
                newFlowConducted.Case__c = newCase.Id;
            }
*/
            //newFlowConducted.Account__c = recordId;
            insert newFlowConducted;
            for(ACN_QuestionniareContainerCtrl.questionWrapper wrapperRes : wrapperResponse){
                if(QuesRespMap.contains(wrapperRes.eachQuesDetails.ACN_Question_Identifier__c) ){
                    ACN_Question_Response__c eachResponse = new ACN_Question_Response__c();
                    eachResponse.ACN_Call_Flow_Conducted__c = newFlowConducted.Id;
                    eachResponse.ACN_Question_Number__c = wrapperRes.eachQuesDetails.ACN_Question_Identifier__c;
                    eachResponse.ACN_Responses__c = wrapperRes.allResponseDetails;
                    eachResponse.ACN_Call_Flow_Template__c = wrapperRes.eachQuesDetails.ACN_Screen__r.ACN_Call_Flow_Template__c;
                    eachResponse.ACN_Question_Description__c = wrapperRes.eachQuesDetails.ACN_Question__r.ACN_Question_Description__c;
                    if(associationTo == 'Case'){
                        eachResponse.Case__c = newCase.Id;
                    }
                    allResponses.add(eachResponse);
                }           
            }
            insert allResponses;
            // system.debug('allResponses : ' + allResponses);
        }
        catch(exception e){
            // System.debug('Exception Occured:: '+e.getMessage());
        }
    }
}