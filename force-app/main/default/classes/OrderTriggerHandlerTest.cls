@isTest
public class OrderTriggerHandlerTest {
    
    @isTest 
    static void testOrderUpdate(){
        Account testAccount = new Account(Name = 'Test Account',Type='Customer');
        insert testAccount;
        
        Contact con = new Contact(LastName ='Dinesh',Phone = '7834878789',AccountId = testAccount.id);
        insert con;
        
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true,ProductCode='abcd',HSN_Code__c='abcd',Type__c='Vehicle');
        insert testProduct;
        
        Id stdPrBk = Test.getStandardPricebookId();
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Product2Id = testProduct.Id,
            Pricebook2Id = stdPrBk,
            UnitPrice = 100.0,	
            IsActive = true
        );
        insert testPricebookEntry;
        
        Asset testAsset = new Asset(Name='Test Asset',AccountId=testAccount.Id,	Product2Id=testProduct.Id);
        insert testAsset;
        
        VehicleDefinition testVD = new VehicleDefinition(Name='Test VehicleDefinition',ProductId=testProduct.Id);
        insert testVD;
        
        Software_Version__c testSV = new Software_Version__c(Name='Test Software Version');
        insert testSV;
        
        Vehicle testVehicle = new Vehicle(Name='Test Vehicle', Account__c=testAccount.Id, AssetId=testAsset.Id,  VehicleDefinitionId=testVD.Id, VehicleIdentificationNumber='A2B3',  Software_Version__c=testSV.Id, Charger_PC_Number__c='abcd',PDI_Status_Pass__c=true);
        insert testVehicle;
        
        AssetMilestone asm = new AssetMilestone(Name = 'ASM1', MilestoneDate = Date.today().addMonths(2),  Stage = 'Active', AssetId = testAsset.Id, UsageType = 'Automotive', MilestoneType = 'PDI', VehicleId = testVehicle.Id);
        insert asm;
        
        Order oldOrder = new Order( AccountId = testAccount.Id, Status__c = 'Processing',Status='Processing',Assigned_Vehicle__c = testVehicle.Id,EffectiveDate = Date.today(),Pricebook2Id = stdPrBk,Payment_Status__c = 'Completed', Contact__c = con.id);
        insert oldOrder;
        oldOrder.Status = 'Activated';
        update oldOrder;
        
        OrderItem testOrderItem = new OrderItem( OrderId = oldOrder.Id, Product2Id = testProduct.Id, UnitPrice = 100.0, Quantity = 1, PricebookEntryId = testPricebookEntry.Id);
        insert testOrderItem;
        
        Test.startTest();
        oldOrder.Status = 'Vehicle Delivered';
        update oldOrder;
        Test.stopTest();
    }
    
    @isTest 
    static void testOrderUpdate1(){
        Account testAccount = new Account(Name = 'Test Account 1',Type='Customer');
        insert testAccount;
        
        Schema.Location testLocation = new Schema.Location(Name = 'Test Location', LocationType = 'State',State__c = 'Karnataka');
        insert testLocation;
        
        Contact con = new Contact(LastName ='Dinesh 1',Phone = '7834878789',AccountId = testAccount.id,Location__c =testLocation.id );
        insert con;
        
        Product2 testProduct = new Product2(Name = 'Test Product 1', IsActive = true,ProductCode='abcd',HSN_Code__c='abcd',Type__c='Vehicle');
        insert testProduct;
        
        Id stdPrBk = Test.getStandardPricebookId();
        
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Product2Id = testProduct.Id,
            Pricebook2Id = stdPrBk,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert testPricebookEntry;
        
        Asset testAsset = new Asset(Name='Test Asset 1',AccountId=testAccount.Id,	Product2Id=testProduct.Id);
        insert testAsset;
        
        VehicleDefinition testVD = new VehicleDefinition(Name='Test VehicleDefinition 1',ProductId=testProduct.Id);
        insert testVD;
        
        Software_Version__c testSV = new Software_Version__c(Name='Test Software Version 1');
        insert testSV;
        
        Vehicle testVehicle = new Vehicle(Name='Test Vehicle 2', Account__c=testAccount.Id, AssetId=testAsset.Id,  VehicleDefinitionId=testVD.Id, VehicleIdentificationNumber='A2B3',  Software_Version__c=testSV.Id, Charger_PC_Number__c='abcd',PDI_Status_Pass__c=true);
        insert testVehicle;
        
        AssetMilestone asm = new AssetMilestone(Name = 'ASM1 2', MilestoneDate = Date.today().addMonths(2),  Stage = 'Active', AssetId = testAsset.Id, UsageType = 'Automotive', MilestoneType = 'PDI', VehicleId = testVehicle.Id);
        insert asm;
        
        Order oldOrder = new Order( AccountId = testAccount.Id, Status__c = 'Processing',Status='Processing',Assigned_Vehicle__c = testVehicle.Id,EffectiveDate = Date.today(),Pricebook2Id = stdPrBk,Payment_Status__c = 'Completed', Contact__c = con.id);
        insert oldOrder;
        
        OrderItem testOrderItem = new OrderItem( OrderId = oldOrder.Id, Product2Id = testProduct.Id, UnitPrice = 100.0,Quantity = 1, PricebookEntryId = testPricebookEntry.Id);
        insert testOrderItem;
        
        Test.startTest();
        oldOrder.Status = 'Activated';
        update oldOrder;
        Test.stopTest();
    }
    
    @isTest
    static void testCreateProductTransfer() {
        Account testAccount = new Account(Name = 'Test Account', Type = 'Customer');
        insert testAccount;
        
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true, ProductCode = 'LTIPK - 001', HSN_Code__c = 'qw12', Type__c= 'Merchandise');
        insert testProduct;
        
        PricebookEntry testPricebookEntry = new PricebookEntry(Product2Id = testProduct.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 100.0, IsActive = true);
        insert testPricebookEntry;
        
        Order testOrder = new Order(AccountId = testAccount.Id, Status = 'Back Order', EffectiveDate = Date.today(), Pricebook2Id = Test.getStandardPricebookId());
        insert testOrder;
        
        ProductRequest testProductRequest = new ProductRequest(ShipmentType = 'VOR', Status = 'New');
        insert testProductRequest;
        
        ProductRequestLineItem testLineItem = new ProductRequestLineItem(ParentId = testProductRequest.Id, Product2Id = testProduct.Id, QuantityRequested = 1);
        insert testLineItem;
        
        testOrder.Purchase_Order__c = testProductRequest.Id;
        update testOrder;
        
        Schema.Location l1 = new Schema.Location(); 
        l1.Name = 'Warehouse 1';
        l1.LocationType = 'Secondary';
        l1.IsInventoryLocation = true;
        insert l1;
        
        ProductItem testProductItem = new ProductItem(Product2Id = testProduct.Id, LocationId = l1.Id, QuantityOnHand =123); 
        insert testProductItem;
        
        OrderItem testOrderItem = new OrderItem(OrderId = testOrder.Id, Product2Id = testProduct.Id, Quantity = 1, PricebookEntryId = testPricebookEntry.Id, UnitPrice = 123);
        insert testOrderItem;
        
        Test.startTest();
        
        testOrder.Status = 'Activated';
        update testOrder;
        Test.stopTest();
    }
    
    @isTest
    static void testMaintainOrderCounter() {
        
        Account testAccount = new Account(Name = 'Test Account', Type = 'Customer', AccountSource = 'Direct');
        insert testAccount;
        
        Account dealerAccount = new Account(Name = 'Dealer Account', Type = 'Dealer', Center_Code__c = '123');
        insert dealerAccount;
        
        Order testOrder = new Order(AccountId = testAccount.Id, Dealer__c = dealerAccount.Id, Status = 'Processing', EffectiveDate = Date.today());
        insert testOrder;
        
        OrderCounter__c counterSetting = new OrderCounter__c(Name = 'Count', Counter__c = 1000);
        insert counterSetting;
        
        Test.startTest();
        
        testOrder.Status = 'Activated';
        update testOrder;
        Test.stopTest();
    }
    //added by Aniket for WhatsApp Integration
    @isTest
     static void testForWhatsAppIntegration(){
        Account testAccount = new Account(Name = 'Test Account',Type='Customer',Phone='0987654321');
        insert testAccount;
        
        Contact con = new Contact(LastName ='Dinesh',Phone = '7834878789',AccountId = testAccount.id);
        insert con;
        
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true,ProductCode='abcd',HSN_Code__c='abcd',Type__c='Vehicle');
        insert testProduct;
        
        Id stdPrBk = Test.getStandardPricebookId();
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Product2Id = testProduct.Id,
            Pricebook2Id = stdPrBk,
            UnitPrice = 100.0,	
            IsActive = true
        );
        insert testPricebookEntry;
        
        Asset testAsset = new Asset(Name='Test Asset',AccountId=testAccount.Id,	Product2Id=testProduct.Id);
        insert testAsset;
        
        VehicleDefinition testVD = new VehicleDefinition(Name='Test VehicleDefinition',ProductId=testProduct.Id);
        insert testVD;
        
        Software_Version__c testSV = new Software_Version__c(Name='Test Software Version');
        insert testSV;
        
        Vehicle testVehicle = new Vehicle(Name='Test Vehicle', Account__c=testAccount.Id, AssetId=testAsset.Id,  VehicleDefinitionId=testVD.Id, VehicleIdentificationNumber='A2B3',  Software_Version__c=testSV.Id, Charger_PC_Number__c='abcd',PDI_Status_Pass__c=true);
        insert testVehicle;
        
        AssetMilestone asm = new AssetMilestone(Name = 'ASM1', MilestoneDate = Date.today().addMonths(2),  Stage = 'Active', AssetId = testAsset.Id, UsageType = 'Automotive', MilestoneType = 'PDI', VehicleId = testVehicle.Id);
        insert asm;
        
        Order oldOrder = new Order( AccountId = testAccount.Id, Status__c = 'Processing',Status='Processing',Assigned_Vehicle__c = testVehicle.Id,EffectiveDate = Date.today(),Pricebook2Id = stdPrBk,Payment_Status__c = 'Completed', Contact__c = con.id,Booking_Form_File_URL__c='test.pdf',Website_Order_Id__c='TestABC!@#',Allotment_In_Process_File_URL__c='testInvoice.pdf');
        insert oldOrder;
        
        
        OrderItem testOrderItem = new OrderItem( OrderId = oldOrder.Id, Product2Id = testProduct.Id, UnitPrice = 100.0,Type__c='Vehicle', Quantity = 1, PricebookEntryId = testPricebookEntry.Id);
        insert testOrderItem;
         
        Order_Invoice__c o = new Order_Invoice__c (Invoice_Type__c='Vehicle Invoice',Order__c=oldOrder.Id,Name='test',Invoice_Number__c='ab1cd2');
        insert o;
         
         WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            order_cancelled__c='example.jpg' 
        );
        insert mockIntegration;
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        
        Test.startTest();
        oldOrder.Status = 'Allotment in Process'; 
        update oldOrder;
        oldOrder.Status='RTO Registration';
        update oldOrder;
        oldOrder.Status='Ready For Delivery';
        update oldOrder;
        oldOrder.Status='Vehicle Delivered';
        update oldOrder; 
        Test.stopTest();
        
        
        
    }
    
    public class HttpCalloutMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
             
            
            String body = req.getBody();
            Map<String, Object> requestBody = (Map<String, Object>)JSON.deserializeUntyped(body);
           
            
            
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}'); // Simulate a successful API response
            return res;
        }
         
    }
    //added by Aniket on 11/02/2025
    @isTest
     static void testForWhatsAppIntegrationAfterCancel(){
        Account testAccount = new Account(Name = 'Test Account',Type='Customer',Phone='0987654321');
        insert testAccount;
        
        Contact con = new Contact(LastName ='Dinesh',Phone = '7834878789',AccountId = testAccount.id);
        insert con;
        
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true,ProductCode='abcd',HSN_Code__c='abcd',Type__c='Vehicle');
        insert testProduct;
        
        Id stdPrBk = Test.getStandardPricebookId();
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Product2Id = testProduct.Id,
            Pricebook2Id = stdPrBk,
            UnitPrice = 100.0,	
            IsActive = true
        );
        insert testPricebookEntry;
        
        Asset testAsset = new Asset(Name='Test Asset',AccountId=testAccount.Id,	Product2Id=testProduct.Id);
        insert testAsset;
        
        VehicleDefinition testVD = new VehicleDefinition(Name='Test VehicleDefinition',ProductId=testProduct.Id);
        insert testVD;
        
        Software_Version__c testSV = new Software_Version__c(Name='Test Software Version');
        insert testSV;
        
        Vehicle testVehicle = new Vehicle(Name='Test Vehicle', Account__c=testAccount.Id, AssetId=testAsset.Id,  VehicleDefinitionId=testVD.Id, VehicleIdentificationNumber='A2B3',  Software_Version__c=testSV.Id, Charger_PC_Number__c='abcd',PDI_Status_Pass__c=true);
        insert testVehicle;
        
        AssetMilestone asm = new AssetMilestone(Name = 'ASM1', MilestoneDate = Date.today().addMonths(2),  Stage = 'Active', AssetId = testAsset.Id, UsageType = 'Automotive', MilestoneType = 'PDI', VehicleId = testVehicle.Id);
        insert asm;
        
        Order oldOrder = new Order( AccountId = testAccount.Id, Status__c = 'Draft',EffectiveDate = Date.today(),Pricebook2Id = stdPrBk,Payment_Status__c = 'Pending', Contact__c = con.id,Booking_Form_File_URL__c='test.pdf',Website_Order_Id__c='TestABC!@#',Allotment_In_Process_File_URL__c='testInvoice.pdf',Status='Draft');
        insert oldOrder;
        
        
        OrderItem testOrderItem = new OrderItem( OrderId = oldOrder.Id, Product2Id = testProduct.Id, UnitPrice = 100.0,Type__c='Vehicle', Quantity = 1, PricebookEntryId = testPricebookEntry.Id);
        insert testOrderItem;
         
        Order_Invoice__c o = new Order_Invoice__c (Invoice_Type__c='Vehicle Invoice',Order__c=oldOrder.Id,Name='test',Invoice_Number__c='ab1cd2');
        insert o;
         
         WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            order_cancelled__c='example.jpg' 
        );
        insert mockIntegration;
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplAfterCancel());
        
        Test.startTest();
        oldOrder.Status = 'Allotment in Process';
        update oldOrder; 
        oldOrder.Status='Order Cancelled';
        update oldOrder;
        Test.stopTest();
        
        
        
    }
    
    public class HttpCalloutMockImplAfterCancel implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
             
            
            String body = req.getBody();
            Map<String, Object> requestBody = (Map<String, Object>)JSON.deserializeUntyped(body);
           
            
            
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}'); // Simulate a successful API response
            return res;
        }
         
    }
    
    
}