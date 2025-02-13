public class ClaimTriggerHandler {
    public static void handleAfterInsert(List<Claim> newClaims) {
        // Collect related Warranty IDs from the Claims
        Set<Id> warrantyIds = new Set<Id>();
        for (Claim claim : newClaims) {
            if (claim.Warranty_Prior__c != null) { // Assuming there's a Warranty lookup on Claim
                warrantyIds.add(claim.Warranty_Prior__c);
            }
        }
    
        if (warrantyIds.isEmpty()) {
            return; // Exit if there are no related warranties
        }
    
        // Step 1: Query related Warranty_Prior__c records to get Job Cards (WorkOrders)
        Map<Id, Id> warrantyToJobCardMap = new Map<Id, Id>();
        for (Warranty_Prior__c warranty : [
            SELECT Id, Job_Card__c FROM Warranty_Prior__c WHERE Id IN :warrantyIds
        ]) {
            if (warranty.Job_Card__c != null) {
                warrantyToJobCardMap.put(warranty.Id, warranty.Job_Card__c);
            }
        }
    
        // Step 2: Query related Job Cards (WorkOrders) to get Vehicle__c
        Map<Id, Id> jobCardToVehicleMap = new Map<Id, Id>();
        for (WorkOrder jobCard : [
            SELECT Id, Vehicle__c FROM WorkOrder WHERE Id IN :warrantyToJobCardMap.values()
        ]) {
            if (jobCard.Vehicle__c != null) {
                jobCardToVehicleMap.put(jobCard.Id, jobCard.Vehicle__c);
            }
        }
    
        // Step 3: Create a combined map of Warranty ID to Vehicle ID
        Map<Id, Id> warrantyToVehicleMap = new Map<Id, Id>();
        for (Id warrantyId : warrantyToJobCardMap.keySet()) {
            Id jobCardId = warrantyToJobCardMap.get(warrantyId);
            if (jobCardToVehicleMap.containsKey(jobCardId)) {
                warrantyToVehicleMap.put(warrantyId, jobCardToVehicleMap.get(jobCardId));
            }
        }
    
        // Step 4: Query WorkOrderLineItems related to the Warranty Prior
        Map<Id, List<WorkOrderLineItem>> warrantyToLineItemsMap = new Map<Id, List<WorkOrderLineItem>>();
        for (WorkOrderLineItem lineItem : [
            SELECT Id, Amount__c, Warranty_Prior__c,Description,Quantity,Hours__c, TotalAmount__c FROM WorkOrderLineItem
            WHERE Warranty_Prior__c IN :warrantyIds
        ]) {
            if (!warrantyToLineItemsMap.containsKey(lineItem.Warranty_Prior__c)) {
                warrantyToLineItemsMap.put(lineItem.Warranty_Prior__c, new List<WorkOrderLineItem>());
            }
            warrantyToLineItemsMap.get(lineItem.Warranty_Prior__c).add(lineItem);
        }

        //querying labour code i.e WorkPlan
        Map <Id, List<WorkPlan>> warrantyToLineItemsClaimMap = new Map<Id, List<WorkPlan>>();
        for(WorkPlan plan: [
            SELECT Id, Warranty_Prior__c, TotalAmount__c FROM WorkPlan WHERE Warranty_Prior__c IN :warrantyIds
        ]){
            if(!warrantyToLineItemsClaimMap.containsKey(plan.Warranty_Prior__c)){
                    warrantyToLineItemsClaimMap.put(plan.Warranty_Prior__c, new List<WorkPlan>());
                }
                warrantyToLineItemsClaimMap.get(plan.Warranty_Prior__c).add(plan);
        }



        // Step 5: Create Claim Items for each Claim
        List<ClaimItem> claimItemsToInsert = new List<ClaimItem>();
        for (Claim claim : newClaims) {
            if (warrantyToLineItemsMap.containsKey(claim.Warranty_Prior__c)) {
                List<WorkOrderLineItem> relatedLineItems = warrantyToLineItemsMap.get(claim.Warranty_Prior__c);
                Integer i = 1;
                for (WorkOrderLineItem lineItem : relatedLineItems) {
                    // Fetch the Vehicle from the Warranty's Job Card (WorkOrder)
                    Id vehicleId = warrantyToVehicleMap.get(claim.Warranty_Prior__c);
    
                    ClaimItem newClaimItem = new ClaimItem(
                        Name      = 'Claim_Item_' + claim.Name +' ' +i,
                        ClaimId   = claim.Id,       // Associate with the Claim
                        Part__c   = lineItem.Id,    // Link to the WorkOrderLineItem
                        Amount__c = lineItem.TotalAmount__c, // Carry over the amount
                        //VehicleId = vehicleId,     // Set the Vehicle from Job Card
                        FaultDate = Date.today(), // Assuming FaultDate is a field
                        Status__c = 'Pending',
                        Claim_Type__c = 'Part'
                        //Consequential_Part__c = lineItem.Consequential_Part__c ,
                        //Part_Description__c = lineItem.Part_Description__c,
                        //Electrical_Value__c = lineItem.Electrical_Value__c,
                        // Quantity__c = lineItem.Quantity,
                        // Hours__c = lineItem.Hours__c

                    );
                    claimItemsToInsert.add(newClaimItem);
                    i++;
                }
            }
            
            if (warrantyToLineItemsClaimMap.containsKey(claim.Warranty_Prior__c)) {
                List<WorkPlan> relatedWorkPlan = warrantyToLineItemsClaimMap.get(claim.Warranty_Prior__c);
                String s = 'lc';
                Integer i = 1;
                for(WorkPlan plan: relatedWorkPlan){
                    ClaimItem newClaimItem = new ClaimItem(
                        Name = 'Claim_Item_' + claim.Name +' ' +s+' ' +i,
                        ClaimId = claim.Id,
                        Claim_Type__c = 'Labour',
                        Status__c = 'Pending',
                        FaultDate = Date.today(),
                        Labour_Code__c = plan.Id

                    );
                    claimItemsToInsert.add(newClaimItem);
                }
            }
        }
    
        // Step 6: Insert all Claim Items
        if (!claimItemsToInsert.isEmpty()) {
            insert claimItemsToInsert;
        }
    
        System.debug('Claim Items Inserted: ' + claimItemsToInsert);
    }
    
}