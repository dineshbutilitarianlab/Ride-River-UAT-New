public with sharing class clainAndShipmentItemController {
    @AuraEnabled(cacheable = true)
    public static List<ShipmentItem> getShipmentItemList(String recordId){
        return [Select id,ShipmentItemNumber,Quantity,Quantity_Received__c,Missing_Damaged_Quantity__c,ShipmentId,Shipment.Status,Product2Id,Product2.Name from ShipmentItem where ShipmentId=:recordId];
    }
    @AuraEnabled
    public static string updateShipmentItemList(List<ShipmentItem> shipmentItemList,String recordId){
        Shipment s = [SELECT Id, Status FROM Shipment WHERE id=:recordId];
        s.Status='Delivered';
        update s;
        update shipmentItemList;
        return 'SUCCESS';
    }
    @AuraEnabled(cacheable = true)
    public static List<Claim> getAllClaims(String recordId){
        return [SELECT Id,Name,ClaimType,Status,Total_Claimed_Amount__c,Create_Batch__c,Create_Batch__r.Name,Create_Batch__r.Is_GRN_Received__c,Shipped_Quantity__c FROM Claim where Create_Batch__c=:recordId ];
    }
    @AuraEnabled(cacheable = true)
    public static List<ClaimItem> getAllClaimItems(String recordId) {
        System.debug('Method getAllClaimItems invoked with recordId: ' + recordId);
        
        try {
            // Query to fetch claim items
            List<ClaimItem> claimItems = [
                SELECT Id, Name, 
                       Claim.ClaimType, 
                       Claim.Name, 
                       Claim_Item_Number__c,
                       Status__c, 
                       Amount__c, 
                       Quantity__c, 
                       Received_Quantity__c,
                       Rejection_Reason__c,
                       Claim.Create_Batch__c, 
                       Claim.Create_Batch__r.Name, 
                       Approved_Quantity__c,
                       Claim.Create_Batch__r.Is_GRN_Received__c, Quantity_Rejected__c,
                       Claim.Shipped_Quantity__c
                FROM ClaimItem 
                WHERE Claim.Create_Batch__c = :recordId
            ];
            
            // Debugging the retrieved claim items
            System.debug('Fetched Claim Items: ' + claimItems);
            
            return claimItems;
        } catch (Exception e) {
            // Debugging and handling exceptions
            System.debug('Exception occurred in getAllClaimItems: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching claim items: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string updateClaims(List<Claim> claimList){
        try {
            Set<Id> batchIds = new Set<Id>();
            for(Claim c : claimList){
                batchIds.add(c.Create_Batch__c);
            }
            Create_Batch__c c = [Select id,Is_GRN_Received__c from Create_Batch__c where id=:batchIds LIMIT 1];
            if(c.Is_GRN_Received__c == false){
                c.Is_GRN_Received__c = true;
            }
            
            update c;
            update claimList;
            return 'SUCCESS';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateClaimItems(List<ClaimItem> claimList) {
        System.debug('Entering updateClaimItems method...');
        try {
            // Log the input list
            System.debug('Received claimList: ' + claimList);
    
            Set<Id> batchIds = new Set<Id>();
            for (ClaimItem c : claimList) {
                System.debug('Processing ClaimItem: ' + c);
                batchIds.add(c.Claim.Create_Batch__c);
            }
    
            // Log the collected batch IDs
            System.debug('Collected batchIds: ' + batchIds);
    
            // Query for the Create_Batch__c record
            Create_Batch__c c = [SELECT Id, Status__c,Is_GRN_Received__c FROM Create_Batch__c WHERE Id = :batchIds LIMIT 1];
            System.debug('Queried Create_Batch__c record: ' + c);
    
            // Check and update Is_GRN_Received__c field
            if (c.Is_GRN_Received__c == false) {
                System.debug('Updating Is_GRN_Received__c to true for batchId: ' + c.Id);
                c.Is_GRN_Received__c = true;
            }
    
            // Perform the update operations
            c.Status__c = 'Received';
            update c;
            System.debug('Updated Create_Batch__c record: ' + c);
    
            update claimList;
            System.debug('Updated ClaimItem records: ' + claimList);
    
            System.debug('Exiting updateClaimItems method with SUCCESS');
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateClaimItemsApprovedQuantityAndReason(String claimItemWrappersJson) {
        System.debug('Entering updateClaimItems method...');
        System.debug('claimItemWrappers...'+ claimItemWrappersJson);
        try {
            List<ClaimItemWrapper> claimItemWrappers = (List<ClaimItemWrapper>) JSON.deserialize(
            claimItemWrappersJson, 
            List<ClaimItemWrapper>.class
        );
            // Collect ClaimItem Ids
            Set<Id> claimItemIds = new Set<Id>();
            for (ClaimItemWrapper wrapper : claimItemWrappers) {
                claimItemIds.add(wrapper.claimItemId);
            }
            System.debug('Claim Item IDs: ' + claimItemIds);
    
            // Query only necessary fields
            Map<Id, ClaimItem> existingClaimItems = new Map<Id, ClaimItem>(
                [SELECT Id, Approved_Quantity__c, Rejection_Reason__c 
                 FROM ClaimItem 
                 WHERE Id IN :claimItemIds]
            );
            System.debug('Existing ClaimItems fetched: ' + existingClaimItems);
    
            List<ClaimItem> claimItemsToUpdate = new List<ClaimItem>();
    
            // Update the queried records with new values
            for (ClaimItemWrapper wrapper : claimItemWrappers) {
                if (existingClaimItems.containsKey(wrapper.claimItemId)) {
                    ClaimItem existing = existingClaimItems.get(wrapper.claimItemId);
                    existing.Approved_Quantity__c = wrapper.approvedQuantity;
                    existing.Rejection_Reason__c = wrapper.rejectionReason;
                    if (wrapper.approvedQuantity > 0) {
                        existing.Status__c = 'Approved';
                    } else {
                        existing.Status__c = 'Rejected';
                    }
                    claimItemsToUpdate.add(existing);
                    System.debug('Updating ClaimItem: ' + existing.Id + ' with Approved Quantity: ' 
                                 + wrapper.approvedQuantity + ' and Rejection Reason: ' + wrapper.rejectionReason);
                } else {
                    System.debug('ClaimItem with Id ' + wrapper.claimItemId + ' not found in database.');
                }
            }
    
            // Perform update if records exist
            if (!claimItemsToUpdate.isEmpty()) {
                update claimItemsToUpdate;
                System.debug('Updated ClaimItem records: ' + claimItemsToUpdate);
            } else {
                System.debug('No ClaimItems to update.');
            }
    
            System.debug('Exiting updateClaimItems method with SUCCESS');
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    

public class ClaimItemWrapper {
    @AuraEnabled public Id claimItemId;
    @AuraEnabled public Integer approvedQuantity;
    @AuraEnabled public String rejectionReason;

    public ClaimItemWrapper() {
    }
    public ClaimItemWrapper(Id claimItemId, Integer approvedQuantity, String rejectionReason) {
        this.claimItemId = claimItemId;
        this.approvedQuantity = approvedQuantity;
        this.rejectionReason = rejectionReason;
    }
}


    }