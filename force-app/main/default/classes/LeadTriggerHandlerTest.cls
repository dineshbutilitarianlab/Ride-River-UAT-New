/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 02-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class LeadTriggerHandlerTest {

    @isTest
    public static void testInsertLead() {
         
        WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            new_lead_book_a_test_ride_03__c='exapmle.jpg',
            rnr_whatsapp_book_test_ride__c='rnr.jpg'
        );
        insert mockIntegration;
        
        Store_Details__mdt dealerCodes1 = new Store_Details__mdt(Name__c='test',Dealer_Code__c='292001',IsActive__c=true);
        Store_Details__mdt dealerCodes2 = new Store_Details__mdt(Name__c='test2',Dealer_Code__c='292002',IsActive__c=true);
        
        List<Lead> leadsToInsert = new List<Lead>();
        Lead l1 = new Lead(LastName = 'Test 1', Company = 'Test Company 1',Status='New', LeadSource = 'Google', Dealer_Code__c = '292001', Phone = '6666666666');
        Lead l2 = new Lead(LastName = 'Test 2', Company = 'Test Company 2', LeadSource = 'Bike Dekho', Dealer_Code__c = '222222', Phone = '8888888888');        
        leadsToInsert.add(l1);
        leadsToInsert.add(l2);
         
                
        Test.startTest();
        
        
        
        
        insert leadsToInsert;
        
        l2.Dealer_Code__c='292001';
        update l2;
        
        
        
  
        
        Test.stopTest();
        
       
        
    }
    @IsTest
    public static void testAfterRNR(){
         WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            new_lead_book_a_test_ride_03__c='exapmle.jpg',
            rnr_whatsapp_book_test_ride__c='rnr.jpg'
        );
        insert mockIntegration;
        
        /*Store_Details__mdt dealerCodes1 = new Store_Details__mdt(Name__c='test',Dealer_Code__c='292001',IsActive__c=true);
        Store_Details__mdt dealerCodes2 = new Store_Details__mdt(Name__c='test2',Dealer_Code__c='292002',IsActive__c=true);*/
        
        List<Lead> leadsToInsert = new List<Lead>();
        Lead l1 = new Lead(LastName = 'Test 1', Company = 'Test Company 1', LeadSource = 'Google', Dealer_Code__c = '292001', Phone = '6666666666');
        Lead l2 = new Lead(LastName = 'Test 2', Company = 'Test Company 2', LeadSource = 'Bike Dekho', Dealer_Code__c = '292002', Phone = '8888888888');        
        leadsToInsert.add(l1);
        leadsToInsert.add(l2);
        
        insert leadsToInsert;
        
        Test.startTest();
        l2.Status='RNR';
        l2.Dealer_Code__c='292001';
        update l1;
        Test.stopTest();
    }
}