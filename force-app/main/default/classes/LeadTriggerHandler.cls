/**
 * @description       :
 * @author            : Aniket Karmakar
 * @group             :
 * @last modified on  : 02-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public class LeadTriggerHandler {
    public static void callQueableMethodForNewLead(List<Lead> newLeads){
        String templateName = 'new_lead_book_a_test_ride_03';
        try{
            List<Store_Details__mdt> dealerCodes = [Select id,Dealer_Code__c,IsActive__c From Store_Details__mdt WHERE IsActive__c = true];
            
            List<Id> newLeadIds = new List<Id>();
            Map<Id,String> newLeadMap = new Map<Id,String>();
            Set<String> storeDealerCodes = new Set<String>();
            
            for(Store_Details__mdt s : dealerCodes){
                storeDealerCodes.add(s.Dealer_Code__c);
            }
            List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
            WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
            String imageUrl = w.new_lead_book_a_test_ride_03__c;
            
            // String templateName = 'new_lead_book_a_test_ride_03';
            if(!newLeads.isEmpty()){
                for(Lead lead : newLeads){
                    if((lead.LeadSource == 'Bike Dekho' || lead.LeadSource =='Facebook'||lead.LeadSource=='Google'||lead.LeadSource=='91Wheels') && storeDealerCodes.contains(lead.Dealer_Code__c) && lead.Phone !=null ){
                        newLeadIds.add(lead.Id);
                        newLeadMap.put(lead.Id,lead.Phone);
                    }
                }
                if(newLeadIds!=null && templateName!=null && imageUrl!=null && newLeadMap!=null){
                    System.enqueueJob(new QueueableForImageTemplateMsg(newLeadIds, templateName, imageUrl, newLeadMap));
                }
            }
            
        }catch(Exception e){
            System.debug('Error is ==>'+e.getMessage());
            System.debug('Error Line ==>'+e.getLineNumber());
            System.debug('Error Cause ==>'+e.getCause());
        }
        
    }
    public static void callQueableMethodForAfterUpdate(List<Lead> newLeads,Map<Id,Lead> oldLeadMap){
        String templateName = 'new_lead_book_a_test_ride_03';
        try{
            List<Store_Details__mdt> dealerCodes = [Select id,Dealer_Code__c,IsActive__c From Store_Details__mdt WHERE IsActive__c = true];
            List<Id> newLeadIds = new List<Id>();
            Map<Id,String> newLeadMap = new Map<Id,String>();
            
            Set<String> storeDealerCodes = new Set<String>();
            
            for(Store_Details__mdt s : dealerCodes){
                storeDealerCodes.add(s.Dealer_Code__c);
            }
            List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
            
            WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
            String imageUrl = w.new_lead_book_a_test_ride_03__c;
            // String templateName = 'new_lead_book_a_test_ride_03';
            
            List<Lead> leadsToUpdate = new List<Lead>();
            if(!newLeads.isEmpty()){
                for(Lead lead : newLeads){
                    if(lead.Dealer_Code__c != oldLeadMap.get(lead.Id).Dealer_Code__c && (lead.LeadSource == 'Bike Dekho' || lead.LeadSource =='Facebook'||lead.LeadSource=='Google'||lead.LeadSource=='91Wheels') && storeDealerCodes.contains(lead.Dealer_Code__c) && lead.Phone !=null &&lead.WhatsApp_Sent_After_Update__c == false){
                        newLeadIds.add(lead.Id);
                        newLeadMap.put(lead.Id,lead.Phone);
                        leadsToUpdate.add(new Lead(Id=lead.Id,WhatsApp_Sent_After_Update__c = true));
                        
                    }
                    
                }
                if(!leadsToUpdate.isEmpty()){
                    update leadsToUpdate;
                }
                if(newLeadIds!=null && templateName!=null && imageUrl!=null && newLeadMap!=null){
                    System.enqueueJob(new QueueableForImageTemplateMsg(newLeadIds, templateName, imageUrl, newLeadMap));
                }
                
            }
            
        }catch(Exception e){
            System.debug('Error is ==>'+e.getMessage());
            System.debug('Error Line ==>'+e.getLineNumber());
            System.debug('Error Cause ==>'+e.getCause());
        }
    }
    public static void callQueueableAfterRNR(List<Lead> newLeadList,Map<Id,Lead> oldLeadMap){
        String templateName = 'rnr_whatsapp_book_test_ride';
        try{
            // List<Store_Details__mdt> dealerCodes = [Select id,Dealer_Code__c,IsActive__c From Store_Details__mdt WHERE IsActive__c = true];
            
            List<Id> newLeadIds = new List<Id>();
            Map<Id,String> newLeadMap = new Map<Id,String>();
            Set<String> storeDealerCodes = new Set<String>();
            // for(Store_Details__mdt s : dealerCodes){
                //     storeDealerCodes.add(s.Dealer_Code__c);
            // }
            List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
            WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
            String imageUrl = w.rnr_whatsapp_book_test_ride__c;
            Set<Id> toGettestDrives = new Set<Id>();
            for(Lead lead : newLeadList){
                toGettestDrives.add(lead.Id);
            }
            List<Lead> leadList = [SELECT Id,Name,Phone,Status,(Select Id from Test_Drives__r) from Lead where Id IN: toGettestDrives];

            if(!leadList.isEmpty()){
                for(Lead l : leadList){
                    if(l.Status == 'RNR' && l.Status != oldLeadMap.get(l.Id).Status && l.Phone !=null && l.Test_Drives__r.isEmpty()){ /*storeDealerCodes.contains(l.Dealer_Code__c) &&*/
                        newLeadIds.add(l.Id);
                        newLeadMap.put(l.Id,l.Phone);
                    }
                }
                System.debug('newLeadIds==>'+newLeadIds);
                System.debug('newLeadMap==>'+newLeadMap);
                
                if(!newLeadIds.isEmpty() && (templateName!=null && imageUrl!=null && newLeadMap!=null)){
                    System.enqueueJob(new QueueableForImageTemplateMsg(newLeadIds, templateName, imageUrl, newLeadMap));
                }
                
            }
        }catch(Exception e){
            System.debug('Error is ===>'+e.getMessage());
            System.debug('Error Line Number  ===>'+e.getLineNumber());
            
        }
        
    }
}