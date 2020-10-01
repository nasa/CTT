/**
 * Underlying_Illness__c Trigger Handler Class
 *
 * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
 * @since   2020-04-26
 */
public without sharing class UnderlyingIllnessTriggerHandler {

    /**
     * Generic onAfterInsert handler
     */
    public static void onAfterInsert(Map<Id, Underlying_Illness__c> newMap) {
        UpdateCaseExportFields(newMap);
    }
    
    /**
     * Generic onAfterUpdate handler
     */
    public static void onAfterUpdate(Map<Id, Underlying_Illness__c> newMap, Map<Id, Underlying_Illness__c> oldMap){
        UpdateCaseExportFields(newMap);
    }

    /**
     * Generic onBeforeDelete handler
     */
    public static void onBeforeDelete(Map<Id, Underlying_Illness__c> oldMap){
        UpdateCaseExportFields(oldMap);
    }
    
    /**
     * Generic onAfterUndelete handler
     */
    public static void onAfterUndelete(Map<Id, Underlying_Illness__c> newMap){
        UpdateCaseExportFields(newMap);
    }

    /**
     * Any change to the Underlying_Illness__c records should trigger a change to the related cases's export fields
     * 
     * NOTE: The child records are not expected to be transferred between Cases -- they can't be reparented, so we aren't checking
     *       for previous Case__c values.
     *
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-26
     */
    public static void UpdateCaseExportFields(Map<Id, Underlying_Illness__c> recMap)
    {
        Set<Id> caseIds = new Set<Id>();

        // Collect Ids of related cases
        for (Underlying_Illness__c rec : recMap.values())
        {
            caseIds.add(rec.Case__c);
        }
        
        // Call the CaseTriggerHandler method to update the export fields -- specify the UnderlyingIllness fields
        CaseTriggerHandler.UpdateExportFields(caseIds, CaseTriggerHandler.objSpec_UnderlyingIllness);
    }
}