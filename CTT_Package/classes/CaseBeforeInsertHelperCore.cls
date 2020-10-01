/*
* Name: CaseBeforeInsertHelperCore
* Author:
* Descritpion: Helper class which is invoked on before insert event of Case object
*/
public virtual class CaseBeforeInsertHelperCore implements TriggerFramework.IHandler {
    /*
    * MethodName: execute
    * Description: This is the first method executed when this event is triggered
    * Parameters:
    *    TriggerFramework.Context: contact object which holds old and new values of the object
    */
    public void execute(TriggerFramework.Context context) {
        
        List<Case> newList = (List<Case>) context.newList;
        Map<Id, Case> newMap = (Map<Id, Case>) context.newMap;
        
        //Invoke core methods        
        copyTeamfromParentToChild(newList);
        FleshOutOutreaches(newList);
        
        //Invoke child class method to execute project specific methods
        CaseBeforeInsertHelper.executeHelper(context);
    }
    
    /*
    * MethodName: copyTeamfromParentToChild
    * Author: Satheesh
    * Description: This method copies data from parent to child case
    * Parameters:
    *    newCases: updated case records
    */
    public virtual void copyTeamfromParentToChild(List<Case> newCases){
        try{
            System.debug('copyTeamfromParentToChild 11');
            system.debug('invoking ContactTracerCaseTriggerHandler1'+newCases);
            ContactTracerCaseTriggerHandler.BeforeInsertHandler(newCases);
            CaseTriggerHandler.copyTeamfromParentToChild(newCases);
        }catch(Exception e){
            System.debug('Exception in copyTeamfromParentToChild -- '+e);
            APS_LogExceptionEventCls.logExceptionEvent(e,'CaseBeforeInsertHelperCore','copyTeamfromParentToChild');
        }
    }
    
    /*
    * MethodName: FleshOutOutreaches
    * Author: Satheesh
    * Description: 
    * Parameters:
    *    newCases: updated case records
    */
    public virtual void FleshOutOutreaches(List<Case> newCases){
        try{
            System.debug('FleshOutOutreaches 11');
            CaseTriggerHandler.FleshOutOutreaches(newCases);
        }catch(Exception e){
            System.debug('Exception in FleshOutOutreaches -- '+e);
            APS_LogExceptionEventCls.logExceptionEvent(e,'CaseBeforeInsertHelperCore','FleshOutOutreaches');
        }
    }
    
}