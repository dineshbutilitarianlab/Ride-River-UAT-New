/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger LeadTrigger on Lead (after insert,after update) {
    if(trigger.isafter && trigger.Isinsert){
        // for(lead leadid:trigger.new){
        //     System.debug('leadid: ' + leadid);
            
            LeadTriggerHandler.callQueableMethodForNewLead(Trigger.new);
           /* string mobileNO=leadid.Phone;
            if((leadid.LeadSource=='Bike Dekho'||leadid.LeadSource=='91Wheels'||leadid.LeadSource=='Facebook'||leadid.LeadSource=='Google')&&(leadid.Lead_Dealer_Code__c=='291001'||leadid.Lead_Dealer_Code__c=='291002'||leadid.Lead_Dealer_Code__c=='292001'||leadid.Lead_Dealer_Code__c=='292002'||leadid.Lead_Dealer_Code__c=='292003'||leadid.Lead_Dealer_Code__c=='362001'||leadid.Lead_Dealer_Code__c=='332001'||leadid.Lead_Dealer_Code__c=='331001'||leadid.Lead_Dealer_Code__c=='321001'||leadid.Lead_Dealer_Code__c=='122001')){
                //WhatsAppApiCalloutHandler.leadcreationmsg(mobileNO,'new_lead_book_a_test_ride_03');
            }else if (Test.isRunningTest()) {
                //WhatsAppApiCalloutHandler.leadcreationmsg(mobileNO,'new_lead_book_a_test_ride_03');
            }*/
//}
    }if(Trigger.isAfter && Trigger.isUpdate){
        LeadTriggerHandler.callQueableMethodForAfterUpdate(Trigger.new,Trigger.oldMap);
        LeadTriggerHandler.callQueueableAfterRNR(Trigger.new,Trigger.oldMap);
        
    }
}