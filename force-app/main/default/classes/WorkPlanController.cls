public with sharing class WorkPlanController {
    @AuraEnabled(cacheable=true)
    public static List<WorkPlan> getRelatedWorkPlans(Id workOrderId) {
         System.debug('Fetching related Work Plans for Work Order Id: ' + workOrderId);
        List<WorkPlan> workplans = [SELECT Id, Name, RR_Labour_Code__r.Code, Status__c, Duration_Hour__c, Labour_Charge__c,CreatedDate, RR_Labour_Code__c,RR_Labour_Category__c,WorkOrder.Status
                                    FROM WorkPlan 
                                    WHERE WorkOrderId =:workOrderId
                                    ORDER BY CreatedDate ASC];
        System.debug('Retrieved related Work Plans: ' + workplans);
        return workplans;
    }

        //additional code by Rohit Singh Bisht on 28/01/2025 for Deleting added Labour code
        @AuraEnabled
        public static void deleteWorkPlanApex(String rowId){
            delete [Select Id from WorkPlan WHERE Id=:rowId];
        }
}