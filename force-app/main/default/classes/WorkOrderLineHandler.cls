public class WorkOrderLineHandler {
    public static void handleActivitiesBeforeDelete(List<WorkOrderLineItem> workOrderLineItems){
          Set<Id> workOrderLineItemIds = new Set<Id>();
        for(WorkOrderLineItem woli : workOrderLineItems){
            workOrderLineItemIds.add(woli.Id);
        }
       List<ProductConsumed> productConsumedList = [
            SELECT Id, ProductItemId, Quantity_Consumed__c
            FROM ProductConsumed
            WHERE WorkOrderLineItemId IN :workOrderLineItemIds
        ]; 
       
         Map<Id, Decimal> productItemQuantityMap = new Map<Id, Decimal>();
      
        for (ProductConsumed pc : productConsumedList){
             if (pc.ProductItemId != null){
                  if (productItemQuantityMap.containsKey(pc.ProductItemId)){
                      
                        Decimal currentQuantity = productItemQuantityMap.get(pc.ProductItemId);
                      
                    productItemQuantityMap.put(pc.ProductItemId, currentQuantity - pc.Quantity_Consumed__c);
                } else {
                    productItemQuantityMap.put(pc.ProductItemId, -pc.Quantity_Consumed__c);
                }
            }
        }

        
        List<ProductItem> productItemsToUpdate = [
            SELECT Id, 	Quantity_In_Hand__c,QuantityOnHand
            FROM ProductItem
            WHERE Id IN :productItemQuantityMap.keySet()
        ];

      
        for (ProductItem pi : productItemsToUpdate) {
            Decimal quantityChange = productItemQuantityMap.get(pi.Id);
            pi.QuantityOnHand += quantityChange; 
        }

      
        if (!productItemsToUpdate.isEmpty()) {
            update productItemsToUpdate;
        }
             }
        }