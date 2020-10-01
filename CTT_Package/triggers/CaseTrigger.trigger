/* -------------------------------------------------------------------------------------------------------------------------------
 * Trigger Name : CaseTrigger
 * Created By : Akanksha Singh
 * Created On : 25-Mar-2020
--------------------------------------------------------------------------------------------------------------------------------------*/
 
trigger CaseTrigger on Case (before insert, after insert, before update, after update){
    
    // Added 2020-03-29 -LC <lawrence.coffin@accenture.com>
    if (Trigger.isBefore && Trigger.isInsert)
    {
        CaseTriggerHandler.onBeforeInsert(Trigger.new);
    }
    
    //if(Trigger.isAfter && Trigger.isInsert/*(Trigger.isInsert || Trigger.isUpdate) */) { 
      //       system.debug('----inside if-----');
        //    CaseTriggerHelper.onAfterInsert(Trigger.new);
        //} 
    if (Trigger.isAfter && Trigger.isInsert) {
        CaseTriggerHandler.onAfterInsert(Trigger.newMap);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        CaseTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        CaseTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    
}