trigger MavenStagingTableTrigger on Maven_Staging_Table__c (before insert) {
        
    if(trigger.isInsert && trigger.isBefore){
        MavenStagingTableTriggerHandler.onBeforeInsert(trigger.new);
    }    
    
    
}