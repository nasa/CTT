/*
 * Name: CaseBeforeUpdateHelperCore
 * Author:
 * Descritpion: Helper class which is invoked on before update event of Case object
 */
public virtual class CaseBeforeUpdateHelperCore implements TriggerFramework.IHandler{
    
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
        Map<Id, Case> oldMap = (Map<Id, Case>)context.oldMap;
        
        list<Case> oldlist = (list<case>)context.oldList;
        
        //Invoke core class methods
        updateTeam(oldMap, newMap);
        
        //Invoke child class method to execute project specific methods
        CaseBeforeUpdateHelper.executeHelper(context);
    }
    
    /*
     * MethodName: updateTeam
     * Author: Satheesh
     * Description: This method updates team of cases
     * Parameters:
     * 	  oldCases: before values of case records
     *    newCases: updated case records
	*/ 
    public virtual void updateTeam(Map<Id, Case> oldCases, Map<Id, Case> newCases){
        try{
            System.debug('updateTeam 11');
            ContactTracerCaseTriggerHandler.BeforeUpdateHandler(oldCases, newCases);
        	CaseTriggerHandler.updateTeam(oldCases, newCases);
        }catch(Exception e){
            System.debug('Exception in updateTeam -- '+e);
		}
    }
}