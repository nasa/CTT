/*
@Author : Abhita Bansal
@Description : This class is used to update the Default Action field in Call Flow screen object.
@since   2020-05-03
**/
public class ACN_UpdateCallFlowScreen{
    
    public static List<ACN_Call_Flow_Screen__c> flowList = new List<ACN_Call_Flow_Screen__c>();
    public static List<String> seqList = new List<String>();
    public static Map<String, String> mapSeqToNum = new Map<String, String>();
    public static List<ACN_Call_Flow_Screen__c> updateFlowList = new List<ACN_Call_Flow_Screen__c>();
    
    @AuraEnabled
    public static void updateDefaultAction(Id templateId){
        
        Integer i = 0;
        
        try{
            flowList = [Select Id, ACN_Default_Action_Screen__c, ACN_Stage_Sequence_No__c, ACN_Screen_Number__c 
                            from ACN_Call_Flow_Screen__c where ACN_Call_Flow_Template__c = :templateId ORDER BY ACN_Stage_Sequence_No__c ASC];
            
            
            for(ACN_Call_Flow_Screen__c flowScreen : flowList){
                seqList.add(String.ValueOf(flowScreen.ACN_Stage_Sequence_No__c));
                mapSeqToNum.put(String.ValueOf(flowScreen.ACN_Stage_Sequence_No__c), flowScreen.ACN_Screen_Number__c );
            }
            
            for(ACN_Call_Flow_Screen__c flowScreen : flowList){
                i++;
                if(i<seqList.size()){
                    flowScreen.ACN_Default_Action_Screen__c = mapSeqToNum.get(seqList[i]);
                    updateFlowList.add(flowScreen);
                }
            }
        
            if(!updateFlowList.isEmpty()){
                update updateFlowList;
            }
        }
        catch (Exception e){
            System.debug('Exception Occured:::: '+e.getMessage());
        }
    }   
}