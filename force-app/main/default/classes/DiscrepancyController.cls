public with sharing class DiscrepancyController {

    @AuraEnabled
    public static String getUserProfile() {
        return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Profile.Name;
    }

    @AuraEnabled(cacheable=true)
    public static List<Discrepancy_Line_Item__c> getLineItems(Id discrepancyId) {
        return [SELECT Id, Name, Supporting_Media__c,Spare_Approval__c,Warehouse_Approval__c FROM Discrepancy_Line_Item__c WHERE Discrepancy__c = :discrepancyId];
    }

    @AuraEnabled
    public static void updateSupportingMedia(Map<Id, Map<String, String>> mediaUpdates) {
        System.debug('mediaUpdates======>'+mediaUpdates);
        List<Discrepancy_Line_Item__c> updates = new List<Discrepancy_Line_Item__c>();
        User usr = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        for (Id itemId : mediaUpdates.keySet()) {
            Discrepancy_Line_Item__c item = new Discrepancy_Line_Item__c(
                Id = itemId,
                Supporting_Media__c = mediaUpdates.get(itemId).get('media')
            );

            if (usr.Profile.Name == 'System Administrator') {
                String status = mediaUpdates.get(itemId).get('status');
                item.Spare_Approval__c = status;
                if(mediaUpdates.get(itemId).ContainsKey('feedback')){
                    String comments = mediaUpdates.get(itemId).get('feedback');
                    system.debug('comments====>'+comments);
                    item.Feedback_From_Spare__c = comments;
                }
                
            } 
            else if (usr.Profile.Name == 'Warehouse') {
                String status = mediaUpdates.get(itemId).get('status');
                item.Warehouse_Approval__c = status;
                if(mediaUpdates.get(itemId).ContainsKey('feedback')){
                    String comments = mediaUpdates.get(itemId).get('feedback');
                    system.debug('comments====>'+comments);
                    item.Feedback_From_Warehosue__c = comments;
                }
                
            }
            
            updates.add(item);
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }


    }