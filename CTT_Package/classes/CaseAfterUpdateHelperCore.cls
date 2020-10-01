/*
 * Name: CaseBeforeUpdateHelperCore
 * Author:
 * Descritpion: Helper class which is invoked on before update event of Case object
 */
public virtual class CaseAfterUpdateHelperCore implements TriggerFramework.IHandler{
   
    /*
     * MethodName: execute
     * Author:Satheesh
     * Description: This is the first method executed when this event is triggered
     * Parameters:
     *    TriggerFramework.Context: contact object which holds old and new values of the object
	*/
    public void execute(TriggerFramework.Context context) {
        List<Case> newList = (List<Case>)context.newList;
        Map<Id, Case> newMap = (Map<Id, Case>)context.newMap;
        
        List<Case> oldList = (List<Case>)context.oldList;
        Map<Id, Case> oldMap = (Map<Id, Case>)context.oldMap;
        
        //Invoke core methods        
        syncHighRiskFieldsToContact(oldMap, newMap);
        
        //Invoke child class method to execute project specific methods
        CaseAfterUpdateHelper.executeHelper(context);
        
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
            System.debug('syncHighRiskFieldsToContact 22');
        	CaseTriggerHandler.syncHighRiskFieldsToContact(oldCases, newCases);
        }catch(Exception e){
            System.debug('Exception in syncHighRiskFieldsToContact -- '+ e);
        }
    }
}