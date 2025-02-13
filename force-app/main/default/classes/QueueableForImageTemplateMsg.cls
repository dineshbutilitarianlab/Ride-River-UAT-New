/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 02-03-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class QueueableForImageTemplateMsg implements Queueable, Database.allowsCallouts{
    private List<Id> leadIds;
    private String templateName;
    private String imageUrl;
    private Map<Id,String> leadIdByPhoneMap;   

    public QueueableForImageTemplateMsg(List<Id> leadIds, String templateName, String imageUrl, Map<Id,String> leadIdByPhoneMap) {
        this.leadIds = leadIds;
        this.templateName = templateName;
        this.imageUrl = imageUrl;
        this.leadIdByPhoneMap = leadIdByPhoneMap;        
    }

    public void execute(QueueableContext qc){        
        if(!leadIds.isEmpty()){
            Id currentLeadId = leadIds.remove(0);
            String phoneNumber = leadIdByPhoneMap.get(currentLeadId);
            System.debug('currentLeadId==>'+currentLeadId);
            System.debug('phoneNumber==>'+phoneNumber);
            if(phoneNumber != null && currentLeadId != null){
                imageTemplateMsg(phoneNumber,templateName,imageUrl);
            }
            
            if(!leadIds.isEmpty() && !Test.isRunningTest()){
                System.enqueueJob(new QueueableForImageTemplateMsg(leadIds, templateName, imageUrl, leadIdByPhoneMap));
            }
        }
    }

    public static void imageTemplateMsg(String phoneNumber,String templateName,String imageUrl){
        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String url = w.API_Endpoint__c !=null ? w.API_Endpoint__c : '';
        String apikey = w.API_Key__c !=null ? w.API_Key__c : '';
        
        String recipientPhoneNumber = '91' + phoneNumber;

        if(recipientPhoneNumber!=null && templateName!=null && imageUrl!=null && url!=null && apikey!=null){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setTimeout(2000);
            request.setHeader('apikey', apikey);
            request.setHeader('Content-Type', 'application/json');
            
            Map<String,Object> payload = new Map<String,Object>();
            Map<String,Object> recipient = new Map<String,Object>();
            recipient.put('id',recipientPhoneNumber);
            
            Map<String,Object> header = new Map<String,Object>();
            Map<String,Object> image = new Map<String,Object>();
            image.put('link',imageUrl);
            header.put('image',image);
            header.put('type','image');
            
            Map<String,Object> template = new Map<String,Object>();
            template.put('parameters', new Map<String, Object>());
            template.put('language','en_US');
            template.put('name',templatename);
            
            payload.put('template',template);
            payload.put('header',header);
            payload.put('type','template');
            payload.put('kookoo_id','OZNTLWA:918197205802');
            payload.put('recipient',recipient);
            
            String reqBody = JSON.serialize(payload);
            System.debug('reqBody==>'+reqBody);
            request.setBody(reqBody);
            
            try {
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
                    System.debug('Success: ' + response.getBody());
                } else {
                    System.debug('Error: ' + response.getStatusCode() + ' ' + response.getBody());
                }
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
        }
        
        
    }
}