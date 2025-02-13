@isTest
public class ClainAndShipmentItemControllerTest {
    @testSetup
    static void setupTestData() {
        Product2 prod = new Product2(Name='Test Product',ProductCode = 'HSN',HSN_Code__c='ASHS', Type__c='Parts');
        insert prod;
        
        Shipment s = new Shipment(Status='Pending',ShipToName = 'Any');
        insert s;
        
        ShipmentItem si = new ShipmentItem(ShipmentId=s.Id, Product2Id=prod.Id, Quantity=10);
        insert si;
        
         /*Create_Batch__c batch = new Create_Batch__c(Is_GRN_Received__c=false);
        insert batch;
        
        Account testAccount = new Account(Name = 'Test Account');
       insert testAccount;
        
        Claim claim = new Claim(Name = 'Claim No 1',Create_Batch__c=batch.Id, ClaimType='Type A', Status='Open',AccountId =testAccount.Id );
        insert claim;
        
        ClaimItem claimItem = new ClaimItem(Name = 'Claim Item no1',ClaimId=claim.Id, Quantity__c=5,FaultDate = Date.Today());
        insert claimItem; */
    }

    @isTest
    static void testGetShipmentItemList() {
        Shipment s = [SELECT Id FROM Shipment LIMIT 1];
        Test.startTest();
        List<ShipmentItem> items = ClainAndShipmentItemController.getShipmentItemList(s.Id);
        Test.stopTest();
        
    }

    @isTest
    static void testUpdateShipmentItemList() {
        Shipment s = [SELECT Id FROM Shipment LIMIT 1];
        List<ShipmentItem> items = [SELECT Id FROM ShipmentItem WHERE ShipmentId = :s.Id];
        Test.startTest();
        String result = ClainAndShipmentItemController.updateShipmentItemList(items, s.Id);
        Test.stopTest();
   
    }

   /*  @isTest
    static void testGetAllClaims() {
        Create_Batch__c batch = [SELECT Id FROM Create_Batch__c LIMIT 1];
        Test.startTest();
        List<Claim> claims = ClainAndShipmentItemController.getAllClaims(batch.Id);
        Test.stopTest();
        System.assertNotEquals(0, claims.size(), 'Claims should be returned.');
    }

    /* @isTest
    static void testGetAllClaimItems() {
        Create_Batch__c batch = [SELECT Id FROM Create_Batch__c LIMIT 1];
        Test.startTest();
        List<ClaimItem> claimItems = ClainAndShipmentItemController.getAllClaimItems(batch.Id);
        Test.stopTest();
        System.assertNotEquals(0, claimItems.size(), 'Claim items should be returned.');
    }

    /* @isTest
    static void testUpdateClaims() {
        List<Claim> claims = [SELECT Id, Create_Batch__c FROM Claim LIMIT 1];
        Test.startTest();
        String result = ClainAndShipmentItemController.updateClaims(claims);
        Test.stopTest();
        System.assertEquals('SUCCESS', result);
    }

    /* @isTest
    static void testUpdateClaimItems() {
        List<ClaimItem> claimItems = [SELECT Id FROM ClaimItem LIMIT 1];
        Test.startTest();
      //  String result = ClainAndShipmentItemController.updateClaimItems(claimItems);
        Test.stopTest();
       // System.assertEquals('SUCCESS', result);
    }

   /* @isTest
    static void testUpdateClaimItemsApprovedQuantityAndReason() {
        ClaimItem claimItem = [SELECT Id FROM ClaimItem LIMIT 1];
        List<ClainAndShipmentItemController.ClaimItemWrapper> wrappers = new List<ClainAndShipmentItemController.ClaimItemWrapper>();
        wrappers.add(new ClainAndShipmentItemController.ClaimItemWrapper(claimItem.Id, 3, 'Damaged'));
        
        String jsonData = JSON.serialize(wrappers);
        Test.startTest();
       // String result = ClainAndShipmentItemController.updateClaimItemsApprovedQuantityAndReason(jsonData);
        Test.stopTest();
        //System.assertEquals('SUCCESS', result);
    } */
}