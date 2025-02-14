public class CaseTriggerHandler {
    
    public static void fireEmailBasedOnCaseTypeAndItsStages(List<Case> cseList){
        try{
            List<EmailTemplate> emailTemplates = [SELECT Id,Subject,Body,Name,HTMLValue FROM EmailTemplate WHERE Folder.Name='Shipment Emails'];
            Map<String,EmailTemplate> mapOfEmailTemplate = new Map<String,EmailTemplate>();
            
            for(EmailTemplate EmailTempRec : emailTemplates){
                mapOfEmailTemplate.put(EmailTempRec.Name,EmailTempRec);
            }
            system.debug('mapOfEmailTemplate=====>'+mapOfEmailTemplate);
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            
            for(Case cse : cseList){
                //Case Open
                if (cse.Case_type__c == 'General Query' && cse.Status == 'Open') {
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    
                    List<String> toAddresses = new List<String>();
                    
                    if (cse.SuppliedEmail != null) {
                        toAddresses.add(cse.SuppliedEmail);
                    } else if (cse.ContactId != null) {
                        mailTemp.setTargetObjectId(cse.ContactId);
                    } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                        toAddresses.add(cse.Account.Email__c);
                    }
                    
                    if (!toAddresses.isEmpty()) {
                        mailTemp.setToAddresses(toAddresses);
                    } else {
                        mailTemp.setTargetObjectId(UserInfo.getUserId());
                    }
                    
                    String emailBody = 'Dear ' + (cse.Contact.Name != null ? cse.Contact.Name : 'Customer') + ',\n\n' +
                        'Thank you for reaching out to River Customer Care. Please find below the details of the query raised with our team.\n\n' +
                        '1) Case No - ' + cse.CaseNumber + '\n' +
                        '2) Query Raised - ' + (cse.Description != null ? cse.Description : 'Not Provided') + '\n\n' +
                        'Our Customer Care Team will reach out to you within the next 24 hours to address your queries.\n' +
                        'If you have any further queries you can reach us at support@rideriver.com or 9731158443.\n\n' +
                        'River Mobility Private Limited\n' +
                        'No. 25/3, KIADB EPIP Zone\n' +
                        'Hoodi Road, Seetharampalya\n' +
                        'Bengaluru, Bengaluru Urban\n' +
                        'Karnataka, 560048\n' +
                        'Email: support@rideriver.com\n' +
                        'Customer Care No - 9731158443';
                    
                    mailTemp.setSubject('Acknowledgment of Your Query - ' + cse.CaseNumber);
                    mailTemp.setPlainTextBody(emailBody);
                    mailTemp.setSaveAsActivity(true);
                    mailTemp.setWhatId(cse.Id);
                    mailList.add(mailTemp);
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
                if (cse.Case_type__c == 'Service Request' && cse.Status == 'RNR') {
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    List<String> toAddresses = new List<String>();
                    
                    if (cse.SuppliedEmail != null) {
                        toAddresses.add(cse.SuppliedEmail);
                    } 
                    else if (cse.ContactId != null) {
                        mailTemp.setTargetObjectId(cse.ContactId);
                    }else if (cse.AccountId != null && cse.Account.Email__c != null) {
                        toAddresses.add(cse.Account.Email__c);
                    }
                    
                    if (!toAddresses.isEmpty()) {
                        mailTemp.setToAddresses(toAddresses);
                    } else {
                        mailTemp.setTargetObjectId(UserInfo.getUserId());
                    }
                    
                    String serviceCenterNumber = cse.Service_Center_Number__c != null ? cse.Service_Center_Number__c : 'Not Available';
                    
                    String emailBody = 'Dear ' + (cse.Contact.Name != null ? cse.Contact.Name : 'Customer') + ',\n\n' +
                        'This is an update regarding your case no- ' + cse.CaseNumber + ' raised with our customer care team.\n' +
                        'Our team is unable to reach you at your registered number, we request to contact our service center at your earliest convenience.\n\n' +
                        'You can connect with the service team at ' + serviceCenterNumber + ' (Service Centre Phone number)\n\n' +
                        'Regards,\nTeam River\n\n' +
                        'River Mobility Private Limited\n' +
                        'No. 25/3, KIADB EPIP Zone\n' +
                        'Hoodi Road, Seetharampalya\n' +
                        'Bengaluru, Bengaluru Urban\n' +
                        'Karnataka, 560048\n' +
                        'Email: support@rideriver.com\n' +
                        'Customer Care No - 9731158443';
                    
                    mailTemp.setSubject('Update Regarding Your Case - ' + cse.CaseNumber);
                    mailTemp.setPlainTextBody(emailBody);
                    mailTemp.setSaveAsActivity(false);
                    mailList.add(mailTemp);
                }
                
                if(cse.Case_type__c == 'PSFU Concerns' && cse.Status == 'RNR' ){
                    
                        system.debug('cse.Account.Email__c ' + cse.Account.Email__c);
                
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Containskey('PSFU Concerns When Case RNR Status')){
                        EmailTemplate getEmailTempId = mapOfEmailTemplate.get('PSFU Concerns When Case RNR Status');
                        mailTemp.setTemplateId(getEmailTempId.Id);
                        
                        if (cse.SuppliedEmail != null) {
                            mailTemp.setToAddresses(new List<String>{cse.SuppliedEmail});
                            System.debug('Email sent to SuppliedEmail: ' + cse.SuppliedEmail);
                        } else if (cse.ContactId != null) {
                            mailTemp.setTargetObjectId(cse.ContactId);
                            System.debug('Email sent to Contact: ' + cse.ContactId);
                        } else if (cse.AccountId != null && cse.Account.Email__c != null) {
                            mailTemp.setToAddresses(new List<String>{cse.Account.Email__c});
                            System.debug('Email sent to Account Email: ' + cse.Account.Email__c);
                        }else {
                            System.debug('No valid email address found!');
                        }
                        
                        mailTemp.setSaveAsActivity(true);
                        mailTemp.setWhatId(cse.Id);
                        mailList.add(mailTemp);
                    }
                }
                
                
            }
            
            if(!mailList.isEmpty()){
                Messaging.sendEmail(mailList);
                System.debug('Emails sent successfully.');
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