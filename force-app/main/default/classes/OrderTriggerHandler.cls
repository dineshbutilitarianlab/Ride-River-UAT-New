/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-12-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class OrderTriggerHandler {
    public static final Id vehicleRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
    
    public static void handleOrderUpdate(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
        // Collect Orders where Status changed to 'Vehicle Delivered'
        try{       
            Set<Id> orderIdsToProcess = new Set<Id>();
            System.debug('oldOrderMap>>'+oldOrderMap);
            System.debug('newOrders>>'+newOrders);
            for (Order newOrder : newOrders) {
                Order oldOrder = oldOrderMap.get(newOrder.Id);
                if (newOrder.Status == 'Vehicle Delivered' && oldOrder.Status != 'Vehicle Delivered') {
                    orderIdsToProcess.add(newOrder.Id);
                    System.debug('oldOrder.Status>>'+oldOrder.Status);
                    System.debug('newOrder.Status>>'+newOrder.Status);
                }
            }
            if (orderIdsToProcess.isEmpty()) {
                return;
            }
            
            System.debug('orderIdsToProcess::::::::' + orderIdsToProcess); 
            
            createAssetsForOrders(orderIdsToProcess);
        } catch (Exception ex) {
            System.debug('Error in handleOrderUpdate: ' + ex.getMessage());
        }
    }
    
    private static void createAssetsForOrders(Set<Id> orderIds) {
        if (orderIds == null) {
            return;
        }
        
        try {
            List<OrderItem> orderItems = [
                SELECT Id, Product2Id, Product2.Name, OrderId, Order.AccountId, 
                Quantity, Total_Price__c, Order.Assigned_Vehicle__c, 
                Order.Assigned_Vehicle__r.VehicleIdentificationNumber, Order.Assigned_Vehicle__r.RR_Battery_Number__c, 
                Order.Assigned_Vehicle__r.EngineNumber,
                Order.Assigned_Vehicle__r.Purchased_Date__c
                FROM OrderItem
                WHERE OrderId IN :orderIds
            ];
            
            List<Asset> assetsToInsert = new List<Asset>();
            System.debug('orderItems>>'+orderItems);
            System.debug('orderItems.size>>'+orderItems.size());
            
            for (OrderItem oI : orderItems) {
                Asset asset = new Asset();
                asset.Name = oI.Product2.Name; 
                asset.Product2Id = oI.Product2Id; 
                asset.AccountId = oI.Order.AccountId;
                asset.Vehicle__c = oI.Order.Assigned_Vehicle__c; 
                //asset.SerialNumber = oI.OrderItemNumber; 
                asset.Status = 'Purchased'; 
                asset.Price = oI.Total_Price__c; 
                asset.Quantity = oI.Quantity; 
                asset.PurchaseDate = oI.Order.Assigned_Vehicle__r.Purchased_Date__c;
                asset.InstallDate = Date.today(); // need to ask what is the value here
                asset.Battery_Number__c = oI.Order.Assigned_Vehicle__r.RR_Battery_Number__c;
                asset.Vehicle_Identification_Number__c = oI.Order.Assigned_Vehicle__r.VehicleIdentificationNumber;
                asset.Motor_Number__c = oI.Order.Assigned_Vehicle__r.EngineNumber;
                
                assetsToInsert.add(asset);
            }
            
            if (!assetsToInsert.isEmpty()) {
                try {
                    insert assetsToInsert;
                } catch (DmlException ex) {
                    System.debug('Error while inserting Assets: ' + ex.getMessage());
                }
            }
            else {
                System.debug('No Assets to insert.');
            }
        } catch (Exception ex) {
            System.debug('Error in createAssetsForOrders: ' + ex.getMessage());
        }
    }
    
    public static void createProductTransferForBackOrder(Map<Id, Order> oldOrderMap, Map<Id, Order> newOrderMap) {
        // 1. product is taggerd, qs 
        
        //Id transferRecordTypeId = Schema.SObjectType.ProductTransfer.getRecordTypeInfosByName().get('Transfer').getRecordTypeId();
        List<ProductTransfer> transfersToCreate = new List<ProductTransfer>();
        
        Set<Id> orderIdsToProcess = new Set<Id>();
        Set<Id> purchaseOrderIds = new Set<Id>();
        Set<Id> product2Ids = new Set<Id>();
        Map<Id, Order> ordersToProcess = new Map<Id, Order>();
        
        // Collect necessary data
        for (Id orderId : newOrderMap.keySet()) {
            Order oldOrder = oldOrderMap.get(orderId);
            Order newOrder = newOrderMap.get(orderId);
            
            if (oldOrder.Status == 'Back Order' && newOrder.Status == 'Activated' && newOrder.Purchase_Order__c != null) {
                orderIdsToProcess.add(orderId);
                purchaseOrderIds.add(newOrder.Purchase_Order__c);
                ordersToProcess.put(orderId, newOrder);
            }
        }
        
        if (orderIdsToProcess.isEmpty()) {
            return; // Nothing to process
        }
        
        // Query Purchase Orders and their Line Items
        Map<Id, ProductRequest> purchaseOrderMap = new Map<Id, ProductRequest>(
            [SELECT Id, DestinationLocationId,
             (SELECT Id, QuantityRequested, Product2Id FROM ProductRequestLineItems)
             FROM ProductRequest WHERE Id IN :purchaseOrderIds]
        );
        
        // Query Order Items
        Map<Id, List<OrderItem>> orderItemsMap = new Map<Id, List<OrderItem>>();
        for (OrderItem oi : [
            SELECT Id, Product2Id, Quantity, OrderId
            FROM OrderItem
            WHERE OrderId IN :orderIdsToProcess
        ]) {
            if (!orderItemsMap.containsKey(oi.OrderId)) {
                orderItemsMap.put(oi.OrderId, new List<OrderItem>());
            }
            orderItemsMap.get(oi.OrderId).add(oi);
            product2Ids.add(oi.Product2Id);
        }
        
        Set<Id> destinationLocationIds = new Set<Id>();
        for (ProductRequest pr : purchaseOrderMap.values()) {
            if (pr.DestinationLocationId != null) {
                destinationLocationIds.add(pr.DestinationLocationId);
            }
        }
        
        Map<Id, ProductItem> productItemMap = new Map<Id, ProductItem>();
        for (ProductItem pi : [
            SELECT Id, Product2Id, LocationId
            FROM ProductItem
            WHERE Product2Id IN :product2Ids AND LocationId IN :destinationLocationIds
        ]) {
            productItemMap.put(pi.Product2Id, pi);
        }
        
        System.debug('orderItemsMap====>'+orderItemsMap);
        System.debug('purchaseOrderMap====>'+purchaseOrderMap);
        System.debug('productItemMap====>'+productItemMap);
        
        // Query Product Items (Product Inventory)
        //purchase ord=er is product request
        
        
        // Create Product Transfers
        for (Id orderId : ordersToProcess.keySet()) {
            Order newOrder = ordersToProcess.get(orderId);
            ProductRequest purchaseOrder = purchaseOrderMap.get(newOrder.Purchase_Order__c);
            List<OrderItem> orderItems = orderItemsMap.get(orderId);
            System.debug('orderItems::::'+orderItems);
            
            if (purchaseOrder != null && orderItems != null) {
                for (OrderItem oi : orderItems) {
                    if (productItemMap.containsKey(oi.Product2Id)) {
                        ProductItem matchingProductItem = productItemMap.get(oi.Product2Id);
                        System.debug('matchingProductItem::::'+ matchingProductItem);
                        
                        ProductTransfer pt = new ProductTransfer();
                        pt.Product2Id = oi.Product2Id;
                        pt.Order__c = orderId;
                        //pt.RecordTypeId = transferRecordTypeId;
                        pt.Order_Product__c = oi.Id;
                        pt.QuantitySent = oi.Quantity;
                        pt.QuantityReceived = 0;
                        pt.Driver_Phone__c = '0';
                        pt.LR_Number__c = '0';
                        pt.DestinationLocationId = purchaseOrder.DestinationLocationId;
                        pt.Product_Inventory__c = matchingProductItem.Id;
                        
                        // need to tag 2 things daily ledger and Shipment Item
                        transfersToCreate.add(pt);
                    }
                }
            }
        }
        
        // Insert Product Transfers
        if (!transfersToCreate.isEmpty()) {
            try {
                insert transfersToCreate;
            } catch (DmlException e) {
                System.debug('Error inserting Product Transfers: ' + e.getMessage());
            }
        }
    }
    
    public static void maintainOrderCounter(List<Order> orderList) {
        OrderCounter__c counterSetting = OrderCounter__c.getInstance('Count');
        
        if (counterSetting == null) {
            System.debug('OrderCounter__c custom setting is not initialized');
            return;
        }
        
        Decimal baseCounter = counterSetting.Counter__c;
        Decimal counter = baseCounter;
        
        Set<Id> accountIds = new Set<Id>();
        Set<Id> dealerIds = new Set<Id>();
        
        for (Order ord : orderList) {
            accountIds.add(ord.AccountId);
            dealerIds.add(ord.Dealer__c);
            
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, AccountSource, Center_Code__c FROM Account WHERE Id IN :accountIds]
        );
        
        Map<Id, Account> dealerMap = new Map<Id, Account>(
            [SELECT Id, Center_Code__c FROM Account WHERE Id IN :dealerIds]
        );
        
        for (Order ord : orderList) {
            Account acc = accountMap.get(ord.AccountId);
            
            if (acc != null && acc.AccountSource != 'River Website' && ord.Website_Order_Id__c==null) {
                System.debug('Counter before increment: ' + counter);
                counter++;
                System.debug('Counter after increment: ' + counter);
                
                
                String paddedCounter = String.valueOf(Integer.valueOf(counter));
                while (paddedCounter.length() < 5) {
                    paddedCounter = '0' + paddedCounter;
                }
                
                
                Account dealerAccount = dealerMap.get(ord.Dealer__c);
                if (dealerAccount != null) {
                    String centerCode = dealerAccount.Center_Code__c;
                    ord.Website_Order_Id__c = 'SB' + centerCode + DateTime.now().format('MMYYYY') + paddedCounter;
                    System.debug('Website_Order_Id__c: ' + ord.Website_Order_Id__c);
                }
            }
        }
        counterSetting.Counter__c = counter;
        update counterSetting;
    }
    //code added by Aniket on 27/01/2025 for WhatsApp Integration
    public static void afterUpdate(List<Order> newOrderList,Map<Id,Order> oldOrderMap){
        try{
            
            //dataSet for Delivery Stage
            List<Id> orderIdsToProcessWhenDelivered = new List<Id>();
            Map<Id,String> orderByPhoneMapWhenDelivered = new Map<Id,String>();
            String templateNameForDelivered = 'indie_deliverd_with_feedback_form';
            
            //dataSet for RTO Stage
            List<Id> orderIdsToProcessWhenRTO = new List<Id>();
            Map<Id,String> orderByPhoneMapWhenRTO = new Map<Id,String>();
            String templateNameForRTO = 'order_status_indie_allocated';
            
            //dataSet for ready for delivery stage
            List<Id> orderIdsToProcessWhenReadyForDelivery = new List<Id>();
            Map<Id,String> orderByPhoneMapWhenReadyForDelivery = new Map<Id,String>();
            String templateNameForReadyForDelivery = 'ready_for_delivery';
            
            //dataSet for order cancelled stage
            List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
            WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
            String imageUrlForOrderCancel = w.order_cancelled__c; 
            List<Id> orderIdsToProcessWhenOrderCancelled = new List<Id>();                                                                                                                                                   
            Map<Id,String> orderByPhoneMapWhenOrderCancelled = new Map<Id,String>();
            String templateNameForOrderCancelled = 'order_cancelled';
            
            //additional validation added by Aniket on 10/02/2025
            Set<Id> orderIdsToFetchOrderProducts = new Set<Id>();

            
            Map<Id,Id> orderAndOrderProductMap = new Map<Id,Id>();
            for(Order order : newOrderList){
                if(vehicleRecordTypeId !=null && order.RecordTypeId == vehicleRecordTypeId && order.Status != oldOrderMap.get(order.Id).Status /*&& order.Status == 'Allotment in Process'*/){
                    orderIdsToFetchOrderProducts.add(order.Id);
                    
                }
            }
            List<OrderItem> orderProductList = [SELECT Id,OrderId,Type__c from OrderItem WHERE OrderId IN:orderIdsToFetchOrderProducts]; 
            for(OrderItem oi : orderProductList){
                if(oi.Type__c == 'Vehicle' && oi.OrderId != null){
                    orderAndOrderProductMap.put(oi.OrderId,oi.Id);
                }
            }
            System.debug('orderAndOrderProductMap===>'+orderAndOrderProductMap);
            //upto this
            //code added on 11/02/2025 by Aniket
            Set<Id> accountIdsToGetAccounts= new Set<Id>();

            for(Order o : newOrderList ){
                if(o.AccountId != null){
                    accountIdsToGetAccounts.add(o.AccountId);
                }
            }
            Map<Id,wrapperForAllotment> toPassToQueueable = new Map<Id,wrapperForAllotment>();
            List<Id> orderIdsToProcess = new List<Id>();
            Map<Id,String> accountIdToNameMap = new Map<Id,String>();
            List<Account> accountList = [Select id,Name from Account where Id IN:accountIdsToGetAccounts];
            for(Account a : accountList){
                accountIdToNameMap.put(a.Id,a.Name);
            } 
            //upto this
            if(!newOrderList.isEmpty()){
                for(Order o : newOrderList){
                    //Id vehicleRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
                    System.debug('vehicleRecordTypeId==>'+vehicleRecordTypeId);
                    if(vehicleRecordTypeId != null && o.RecordTypeId == vehicleRecordTypeId){
                        if( o.Status != oldOrderMap.get(o.Id).Status && o.AccountId != null && o.Phone__c!=null){
                            if(o.Status == 'Allotment in Process'){
                                if(orderAndOrderProductMap.containsKey(o.Id)){
                                    if(o.Assigned_Vehicle__c != null && o.Allotment_In_Process_File_URL__c !=null){

                                        orderIdsToProcess.add(o.Id);
                                        wrapperForAllotment w2 = new wrapperForAllotment();
                                        w2.phoneNumber=o.Phone__c;
                                        w2.allotMentFileLinks=o.Allotment_In_Process_File_URL__c;
                                        w2.fileName= accountIdToNameMap.containsKey(o.AccountId) ?  accountIdToNameMap.get(o.AccountId)+ 'allotment' : '';
                                        toPassToQueueable.put(o.Id,w2);
                                    }  
                                }
                                
                            }
                             else if(o.Status == 'Vehicle Delivered'){
                                if(orderAndOrderProductMap.containsKey(o.Id)){
                                    orderByPhoneMapWhenDelivered.put(o.Id,o.Phone__c);
                                    orderIdsToProcessWhenDelivered.add(o.Id); 
                                }
                                  
                            }else if(o.Status == 'RTO Registration'){
                                if(orderAndOrderProductMap.containsKey(o.Id)){
                                orderByPhoneMapWhenRTO.put(o.Id,o.Phone__c);
                                orderIdsToProcessWhenRTO.add(o.Id);  
                                }
                                
                            }else if(o.Status == 'Ready For Delivery'){
                                if(orderAndOrderProductMap.containsKey(o.Id)){
                                    orderByPhoneMapWhenReadyForDelivery.put(o.Id,o.Phone__c);
                                    orderIdsToProcessWhenReadyForDelivery.add(o.Id);  
                                }
                                
                            }else if(o.Status == 'Order Cancelled'){
                                if(orderAndOrderProductMap.containsKey(o.Id)){
                                    orderByPhoneMapWhenOrderCancelled.put(o.Id,o.Phone__c);
                                    orderIdsToProcessWhenOrderCancelled.add(o.Id);  
                                
                                
                            }
                        
                    }
                    }
                }
                    
                }
                system.debug('orderByPhoneMap ===> ' + orderByPhoneMapWhenDelivered);
                system.debug('orderIdsToProcess ===> ' + orderIdsToProcessWhenDelivered);
                
                if(!orderIdsToProcess.isEmpty()){
                    System.enqueueJob(new QueueableOnOrderAllotmentProcess(orderIdsToProcess,toPassToQueueable));
                }
                if(!orderIdsToProcessWhenDelivered.isEmpty() &&(templateNameForDelivered!=null && orderByPhoneMapWhenDelivered!=null)){
                    System.enqueueJob(new QueueableTempWithoutParams(orderIdsToProcessWhenDelivered, templateNameForDelivered, orderByPhoneMapWhenDelivered));
                }
                if(!orderIdsToProcessWhenRTO.isEmpty() &&(templateNameForRTO!=null && orderByPhoneMapWhenRTO!=null)){
                    System.enqueueJob(new QueueableTempWithoutParams(orderIdsToProcessWhenRTO, templateNameForRTO, orderByPhoneMapWhenRTO));
                }
                if(!orderIdsToProcessWhenReadyForDelivery.isEmpty()&&(templateNameForReadyForDelivery !=null && orderByPhoneMapWhenReadyForDelivery!=null)){
                    System.enqueueJob(new QueueableTempWithoutParams(orderIdsToProcessWhenReadyForDelivery, templateNameForReadyForDelivery, orderByPhoneMapWhenReadyForDelivery));
                }
                if(!orderIdsToProcessWhenOrderCancelled.isEmpty()&&(templateNameForOrderCancelled!=null&&imageUrlForOrderCancel!=null && orderByPhoneMapWhenOrderCancelled!=null)){
                    System.enqueueJob(new QueueableForImageTemplateMsg(orderIdsToProcessWhenOrderCancelled, templateNameForOrderCancelled,imageUrlForOrderCancel, orderByPhoneMapWhenOrderCancelled));
                }               
            }
        }catch(Exception e){
            system.debug('error ===> ' + e.getMessage());
            system.debug('error Line===> ' + e.getLineNumber());
        }
    }
    //code added by Aniket on 11/02/2025
    public static void sendWhatsAppAfterOrderCreation(List<Order> newOrderList){
        try{
            List<Id> orderIdsToProcess = new List<Id>();
            Set<Id> orderIdsToGet = new Set<Id>();
            Map<Id,String> orderToProductColor = new Map<Id,String>();
            Map<Id,wrapperForBooking> toPassToQueueable = new Map<Id,wrapperForBooking>();
            for(Order o : newOrderList){
                if(o.RecordTypeId == vehicleRecordTypeId && o.AccountId !=null && o.Assigned_Vehicle__c != null ){
                    orderIdsToGet.add(o.Id);
                    
                }
            }
            System.debug('orderIdsToGet==>'+orderIdsToGet);
            
            List<Order> ordersToProcess = [Select id,Phone__c,RecordTypeId,Assigned_Vehicle__r.Colour__c,Assigned_Vehicle__c,Account.Name,Website_Order_Id__c,Booking_Form_File_URL__c from Order WHERE Id IN:orderIdsToGet];
            System.debug('ordersToProcess==>'+ordersToProcess);
            for(Order order : ordersToProcess){
                 if(order.RecordTypeId == vehicleRecordTypeId){
                    orderIdsToProcess.add(order.Id);
                    orderToProductColor.put(order.Id,order.Assigned_Vehicle__r.Colour__c);
    
                    wrapperForBooking w = new wrapperForBooking();
                    w.phoneNumber = order.Phone__c;
                    w.bookingId = order.Website_Order_Id__c;
                    w.color = order.Assigned_Vehicle__r.Colour__c;
                    w.pdfLink = order.Booking_Form_File_URL__c;
                    w.fileName = order.Account.Name + 'receipt';
                    toPassToQueueable.put(order.Id,w);
                 }
            }
            System.debug('toPassToQueueable==>'+toPassToQueueable);
            if(!orderIdsToProcess.isEmpty()){
                 System.enqueueJob(new QueueableOnOrderCreationAfterBooking(orderIdsToProcess,toPassToQueueable));
            }
        }catch(Exception e){
            System.debug('Error occured==>'+e.getMessage());
            System.debug('Eroor Line Number is =====>'+e.getLineNumber());
        }
        

            
    }
    public class wrapperForBooking{
        public String phoneNumber{get;set;}
        public String bookingId{get;set;}
        public String color{get;set;}
        public String pdfLink{get;set;}
        public String fileName{get;set;}
   }
   public class wrapperForAllotment{
        public String phoneNumber{get;set;}
        public String allotMentFileLinks{get;set;}
        public String fileName{get;set;}
   }
}