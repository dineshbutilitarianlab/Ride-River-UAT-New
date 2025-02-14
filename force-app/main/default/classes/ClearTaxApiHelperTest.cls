@isTest
public class ClearTaxApiHelperTest {
    
    static testMethod void testGetAccessToken() {
        Test.startTest();
        String mockResponse = '{"access_token": "mock_access_token"}';        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, mockResponse));
        String token = ClearTaxApiHelper.getAccessToken();
        Test.stopTest();
    }
    
    @testSetup
    static void setupTestData() {
        // Create Test Account (Seller)
        Account seller = new Account(Name = 'Test Seller', Company_GSTIN_name__c = '29TESTGSTIN', Type = 'Dealer', BillingPostalCode = '431809');
        insert seller;
        
        // Create Test Account (Buyer)
        Account buyer = new Account(Name = 'Test Buyer', Company_GSTIN_name__c = '29BUYERGSTIN', BillingPostalCode = '431807');
        insert buyer;
        
        // Get Standard Pricebook ID
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        // Create a new Product2 record
        Product2 product = new Product2(
            Name = 'Test Product',
            ProductCode = 'TP-001',
            IsActive = true,
            HSN_Code__c = 'DFGHJ',
            Type__c = 'Accessories'
        );
        insert product;
        
        // Create a PricebookEntry to associate the product with a pricebook
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = product.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert pbe;
        
        // Create Order (Set Pricebook2Id)
        Order testOrder = new Order(
            Name = 'Test Order',
            AccountId = buyer.Id,
            Dealer__c = seller.Id,
            Is_IGST_on_Intrastate__c = true,
            EffectiveDate = system.today(),
            Status = 'Draft',
            Pricebook2Id = standardPricebook.Id  // **Fix: Set Pricebook2Id**
        );
        insert testOrder;
        
        // Create Order Item - Use PricebookEntryId
        OrderItem testItem = new OrderItem(
            OrderId = testOrder.Id, 
            PricebookEntryId = pbe.Id,  
            Quantity = 2, 
            UnitPrice = 100
        );
        insert testItem;
        
        // Create Custom Setting
        ClearTax_Api_Details__c apiDetails = new ClearTax_Api_Details__c(
            Name = 'ClearTax Api',
            BaseURL_AccessToken__c = 'https://api.cleartax.in/access-token',
            Client_Secret__c = 'test_secret',
            E_Invoice_Base_URL__c = 'https://api-sandbox.clear.in/einv/v2/eInvoice/generate'
        );
        insert apiDetails;
    }
    
    static testMethod void testGenerateEInvoice() {
        Test.startTest();
        // Mock API Response
        String mockResponse ='{"access_token": "mock_access_token"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, mockResponse));
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        String response = ClearTaxApiHelper.generateEInvoice(testOrder.Id);
        // String response1 = ClearTaxApiHelper.generateAndStoreQRCode('TEST DATA',testOrder.Id);
        Test.stopTest();
    }
    
    
    static testMethod void testgenerateAndStoreQRCode() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, Blob.valueOf('Blob Data')));
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        String response1 = ClearTaxApiHelper.generateAndStoreQRCode('TEST DATA',testOrder.Id);
        String response2 = ClearTaxApiHelper.genereteE_invoicePDF(testOrder.Id);
        Test.stopTest();
    }
    
}