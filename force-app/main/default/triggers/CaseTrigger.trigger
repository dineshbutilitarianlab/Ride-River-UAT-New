trigger CaseTrigger on Case (before insert, before Update,after Insert,after update) {
    
     /*for (Case c : Trigger.new) {
        if (c.Origin == 'Email') {
            c.Case_Type__c = 'General Query';
            system.debug(c);
        }
    } */
    if(trigger.isAfter && trigger.isInsert){
        CaseTriggerHandler.fireEmailBasedOnCaseTypeAndItsStages(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
        CaseTriggerHandler.createTaskForCaseOwnerWhenCaseClosed(trigger.new);
        CaseTriggerHandler.fireEmailBasedOnCaseTypeAndItsStages(trigger.new);
    }
}