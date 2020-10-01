/*
 * Name: CaseAfterInserHelperCore
 * Author:
 * Descritpion: Helper class which is invoked on After insert event of Case object
 */
public virtual class CaseAfterInsertHelperCore implements TriggerFramework.IHandler{
    /*
     * MethodName: execute
     * Description: This is the first method executed when this event is triggered
     * Parameters:
     *    TriggerFramework.Context: contact object which holds old and new values of the object
	*/
    public void execute(TriggerFramework.Context context) {
        List<Case> newList = (List<Case>)context.newList;
        Map<Id, Case> newMap = (Map<Id, Case>)context.newMap;
 		
		//Core package methods invocation        
        syncHighRiskFieldsToContact(null, newMap);
        
        //Project specific handler invocation
        CaseAfterInsertHelper.executeHelper(context);
    }
	
	 /*
     * MethodName: syncHighRiskFieldsToContact
     * Author: Satheesh
     * Description: This method updates high risk fields to contact records
     * Parameters:
     * 	  oldCases: before values of case records
     *    newCases: updated case records
	*/    
    public virtual void syncHighRiskFieldsToContact(Map<Id, Case> oldCases, Map<Id, Case> newCases){
        try{
            System.debug('syncHighRiskFieldsToContact 11');
        	CaseTriggerHandler.syncHighRiskFieldsToContact(oldCases, newCases);
        }catch(Exception e){
             System.debug('Error in CaseAfterInsertHelperCore: syncHighRiskFieldsToContact -- '+e);
			 APS_LogExceptionEventCls.logExceptionEvent(e,'CaseAfterInsertHelperCore','syncHighRiskFieldsToContact');
		}
    }
}