@istest
public class RSACalloutHandler_test {
   @istest
    public static Id getchasisnumbertestforstatusvehicleallocation() {
        List<Order> ordlist = new List<Order>(); 
        
        Account Acc = new Account();
        Acc.Name = 'test';
        insert Acc;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = Acc.Id;
        con.Phone = '0000000000';
        insert con;
        
        Asset a = new Asset();
        a.Name = 'Test';
        a.ContactId = con.Id;
        a.AccountId = Acc.Id;
        insert a;
        
        Product2 p = new Product2();
        p.ProductCode = 'testpro';
        p.Name = 'test';
       // p.Name = 'Road Side Assistance';
        p.Type__c = 'Accessories';
        p.HSN_Code__c = '00000000';
        insert p; 
        
        // Query Standard Pricebook
        
        VehicleDefinition vd = new VehicleDefinition();
        vd.Name = 'VehicleDefinitiontest';
        vd.ProductId = p.Id;
        insert vd;
        
        Software_Version__c sv = new Software_Version__c();
        insert sv;
        
       /* Vehicle v = new Vehicle();
        v.Name = 'test';
        v.VehicleIdentificationNumber = 'Test00001223';
        v.VehicleDefinitionId = vd.Id;
        v.Charger_PC_Number__c = '000000000';
        v.Software_Version__c = sv.Id;
        v.PDI_Status_Pass__c = true;
        v.AssetId = a.Id;
        insert v;*/
        
         Vehicle v = new Vehicle();
        v.Name = 'test';
        v.VehicleIdentificationNumber = 'Test00001223';
        v.VehicleDefinitionId = vd.Id;
        v.Charger_PC_Number__c = '000000000';
        v.Software_Version__c = sv.Id;
        v.PDI_Status_Pass__c = true;
        v.AssetId = a.Id;
        v.CurrentOwnerId = Acc.Id; // Assign to Account
        v.RSA_Activation__c = false; // Ensure this matches the query condition
        insert v;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'test';
        insert pb; 
        
        
        
        Order o = new Order();
        o.Pricebook2Id = pb.Id;  
        o.AccountId = Acc.Id;
        o.Payment_Status__c = 'Completed';
        o.Status = 'Activated';
        o.EffectiveDate = Date.today();
        o.Assigned_Vehicle__c = v.Id;
        insert o; 
        
         
        
         
        
        list<Pricebook2> standardPricebook = [SELECT Id,IsStandard,IsActive FROM Pricebook2];
        Id standardPricebookcostumproduct;
        for(Pricebook2 ppb:standardPricebook){
            if(ppb.IsStandard==true){
                PricebookEntry standardPriceEntry = new PricebookEntry();
                standardPriceEntry.Pricebook2Id = ppb.Id;
                standardPriceEntry.Product2Id = p.Id;
                standardPriceEntry.UnitPrice = 10000.00; // Set the standard price
                standardPriceEntry.IsActive = true;
                insert standardPriceEntry;
                PricebookEntry pe = new PricebookEntry();
                pe.IsActive = true;
                pe.UnitPrice = 10000.00;
                pe.Pricebook2Id =ppb.Id ;  
                pe.Product2Id = p.Id;  
                insert pe;
                OrderItem Oitem = new OrderItem();
                Oitem.Product2Id = p.Id;
                Oitem.OrderId = o.Id;
                Oitem.UnitPrice = pe.UnitPrice;
                Oitem.PricebookEntryId = pe.Id;
                Oitem.Quantity = 1;
                insert Oitem;
                system.debug('Orderidtest'+o.Id);
                
                standardPricebookcostumproduct=pe.Id;
                
            }
        }
       
        
        
        
        
        return o.Id;
        
    }
    
    @istest
    public static void getchasisnumbertestforstatusvehicleallocationtest() {
        Id orderid = RSACalloutHandler_test.getchasisnumbertestforstatusvehicleallocation();
        Order ord = [SELECT Id, Status,RSA_Active__c FROM Order WHERE Id = :orderid];
        //added 
       
        //added
        //OrderItem orderItem = [SELECT Id FROM OrderItem WHERE OrderId = :ord.Id LIMIT 1];//added now
        
        ord.Status = 'Ready For Delivery';
        ord.RSA_Active__c=true;
        update ord;
        List<Order> orderlst = new List<Order>();
        // Test.startTest();
        // RSACalloutHandler.getchasisnumber(orderlst);
        Test.setMock(HttpCalloutMock.class, new RSACalloutMock());
        // Test.stopTest();
        
    }
    
    @istest
    public static void getchasisnumbertestforstatusvehicleallocationtestupdatereg() {
        Id orderid = RSACalloutHandler_test.getchasisnumbertestforstatusvehicleallocation();
        Order ord = [SELECT Id, Status,RSA_Active__c FROM Order WHERE Id = :orderid];
        
        // OrderItem orderItem = [SELECT Id FROM OrderItem WHERE OrderId = :ord.Id LIMIT 1];//added now
        
        ord.Status = 'Payment Pending';
        ord.RSA_Active__c = true;
        ord.Payment_Status__c = 'Completed';
        update ord;
        Test.setMock(HttpCalloutMock.class, new RSACalloutMock());
        
        
        
        
        
    }
    
    //test class method Added by Aniket on 16/01/2025
    @isTest
    public static void testGetChasisNumberWithoutVehicleOrder() {
        
        
        Id orderId = RSACalloutHandler_test.getchasisnumbertestforstatusvehicleallocation();//getchasisnumberWihtoutVehicleOrder
        
        Order_Invoice__c oi = new Order_Invoice__c(Order__c=orderId,Name='Test Invoice',Invoice_Number__c='i12Ac4',Invoice_Type__c='Vehicle Invoice',
                                                   Invoice_date__c=System.Today());
        insert oi;
        
        
          


        
        
        Order order = [SELECT Id, Status, RSA_Active__c FROM Order WHERE Id = :orderId];
        
       
        
        
        
        order.Status = 'RTO Registration';
        order.RSA_Active__c = false;
        update order;
        
        
        
        
        
        //Test.setMock(HttpCalloutMock.class, new RSACalloutMock());
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RSACalloutMock());
        RSACalloutHandler.getchasisnumberWihtoutVehicleOrder(new List<Order>{order});
        
        Test.stopTest();
        
        
    }
    
}