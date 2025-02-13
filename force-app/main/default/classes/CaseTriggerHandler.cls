public class CaseTriggerHandler {
    
    public static void fireEmailBasedOnCaseTypeAndItsStages(List<Case> cseList){
        try{
            List<EmailTemplate> emailTemplates = [SELECT Id,Subject,Body,Name FROM EmailTemplate WHERE Folder.Name='Shipment Emails'];
            Map<String,EmailTemplate> mapOfEmailTemplate = new Map<String,EmailTemplate>();
            
            for(EmailTemplate EmailTempRec : emailTemplates){
                mapOfEmailTemplate.put(EmailTempRec.Name,EmailTempRec);
            }
            system.debug('mapOfEmailTemplate=====>'+mapOfEmailTemplate);
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            
            for(Case cse : cseList){
                //Case Open
                if(cse.Case_type__c == 'General Query' && cse.Status == 'Open' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('General Query When Case Open')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('General Query When Case Open');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                if(cse.Case_type__c == 'Complaint' && cse.Status == 'Open' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('Complaint when Case Open')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('Complaint when Case Open');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                if(cse.Case_type__c == 'Urgent Complaint' && cse.Status == 'Open' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('Urgent Complaint When Case Open')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('Urgent Complaint When Case Open');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                if(cse.Case_type__c == 'Service Request' && cse.Status == 'Open' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('Service Request When Case Open')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('Service Request When Case Open');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                if(cse.Case_type__c == 'PSFU Concerns' && cse.Status == 'Open' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('PSFU Concerns When Case Open')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('PSFU Concerns When Case Open');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                //Case Closed
                if(cse.Case_type__c == 'General Query' && cse.Status == 'Closed' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('General Query When Case is Closed')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('General Query When Case is Closed');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                if(cse.Case_type__c == 'Complaint' && cse.Status == 'Closed' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('Complaint when Case Is Closed')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('Complaint when Case Is Closed');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                if(cse.Case_type__c == 'Urgent Complaint' && cse.Status == 'Closed' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('Urgent Complaint When Case Is Closed')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('Urgent Complaint When Case Is Closed');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                if(cse.Case_type__c == 'PSFU Concerns' && cse.Status == 'Closed' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('PSFU Concerns When Case Is Closed')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('PSFU Concerns When Case Is Closed');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                //Case RNR
                if(cse.Case_type__c == 'General Query' && cse.Status == 'RNR' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('General Query When Case RNR Status')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('General Query When Case RNR Status');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                if(cse.Case_type__c == 'Complaint' && cse.Status == 'RNR' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('Complaint when Case RNR Status')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('Complaint when Case RNR Status');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                if(cse.Case_type__c == 'Urgent Complaint' && cse.Status == 'RNR' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('Urgent Complaint When Case RNR Status')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('Urgent Complaint When Case RNR Status');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                if(cse.Case_type__c == 'Service Request' && cse.Status == 'RNR' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('Service Request When Case RNR Status')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('Service Request When Case RNR Status');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                if(cse.Case_type__c == 'PSFU Concerns' && cse.Status == 'RNR' ){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('PSFU Concerns When Case RNR Status')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('PSFU Concerns When Case RNR Status');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                
            }
            
            if(!mailList.isEmpty()){
                Messaging.sendEmail(mailList);
            }
        }catch (Exception e) {
            System.debug('Error Message ==>' + e.getMessage() + ' && Error Line ==>' + e.getLineNumber()); 
        }
    }
    
    public static void createTaskForCaseOwnerWhenCaseClosed(List<Case> caseList){
        List<Task> tskRecList = new List<Task>();
        for(Case cse: caseList){
            Task tskRec = new Task();
            if(cse.Case_type__c == 'PSFU Concerns' || cse.Case_type__c == 'Urgent Complaint' || cse.Case_type__c == 'Complaint'){
                tskRec.WhatId = cse.Id;
                tskRec.Subject = 'Closed Case Follow Up';
                tskRec.Status = 'Not Started';
                tskRec.ActivityDate = system.today();
                tskRec.Priority = 'High';
                tskRecList.add(tskRec);
            }
        }
        
        if(!tskRecList.isEmpty()){
            Insert tskRecList;
        }
    }
    
}