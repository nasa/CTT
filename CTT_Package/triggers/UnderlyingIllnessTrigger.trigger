/**
 * Trigger code for Underlying_Illness__c
 * 
 * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
 * @since   2020-04-26
 */
trigger UnderlyingIllnessTrigger on Underlying_Illness__c (after insert, after update, before delete, after undelete) {
    
    if (Trigger.isAfter && Trigger.isInsert)
    {
        UnderlyingIllnessTriggerHandler.onAfterInsert(Trigger.newMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate)
    {
        UnderlyingIllnessTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }

    if (Trigger.isBefore && Trigger.isDelete)
    {
        UnderlyingIllnessTriggerHandler.onBeforeDelete(Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isUndelete)
    {
        UnderlyingIllnessTriggerHandler.onAfterUndelete(Trigger.newMap);
    }
}