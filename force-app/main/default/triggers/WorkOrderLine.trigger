trigger WorkOrderLine on WorkOrderLineItem (before delete){
    if(trigger.isBefore && trigger.isDelete){
        WorkOrderLineHandler.handleActivitiesBeforeDelete(trigger.old);
    }
 
}