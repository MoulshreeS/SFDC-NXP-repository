/************************************************************************
@Created By :    Gunjan Singh
@Created Date:   11 Nov 2019
@Description:    Created as part of SFDC-3465 File Upload as per conditions.
----------------------------------------------------------------------------------------
@Modified By :   Nisha Agrawal
@Modified Date:  Jan 24, 2020
@Description:    Optimised the code and resolved below listed issues - 
         1. file could not be deleted for non TS community cases
         2. files could not be uploaded on non TS community cases
************************************************************************************************/
public class ContentDocLinkTriggerHelper {
    
//Method to restrict the uploading of files for the user on some criteria
    public static void restrictUploadingFiles(List<ContentDocumentLink> lstContentDocLink)
    {   
        Id customerCommunityProfileId;
        Id customerCommunityPlusProfileId;
        Id internalFAEProfileId;
        Id partnerCommunityProfileId; 
        Id internalAgentProfileId;
        
        for(Profile objProfile : [SELECT Id, Name FROM Profile WHERE Name =: CasePortalUtil.COMMUNITY_USER_PROFILE 
                                            OR Name =: CasePortalUtil.COMMUNITY_PLUS_USER_PROFILE 
                                            OR Name =: CasePortalUtil.INTERNAL_FAE_PROFILE
                                            OR Name =: CasePortalUtil.INTERNAL_AGENT_PROFILE
                                            OR Name =: LeadPortalLib.LP_EXTERNAL_PROFILE])
            {
                if(objProfile.Name == CasePortalUtil.COMMUNITY_USER_PROFILE)
                {
                   customerCommunityProfileId = objProfile.Id; 
                }
                else if(objProfile.Name == CasePortalUtil.COMMUNITY_PLUS_USER_PROFILE)
                {
                    customerCommunityPlusProfileId = objProfile.Id; 
                }
                else if(objProfile.Name == CasePortalUtil.INTERNAL_FAE_PROFILE)
                {
                    internalFAEProfileId = objProfile.Id; 
                }
                else if(objProfile.Name == LeadPortalLib.LP_EXTERNAL_PROFILE)
                {
                    partnerCommunityProfileId = objProfile.Id; 
                }
                else if(objProfile.Name == CasePortalUtil.INTERNAL_AGENT_PROFILE)
                {
                    internalAgentProfileId = objProfile.Id;
                }            
            }
            
        Id currentUserProfileId = UserInfo.getProfileId();
        //restrict file upload if current user belongs to one of these profile
        if(currentUserProfileId == customerCommunityProfileId || currentUserProfileId == customerCommunityPlusProfileId ||
           currentUserProfileId == internalFAEProfileId|| currentUserProfileId == partnerCommunityProfileId || currentUserProfileId == internalAgentProfileId)
        {
            Map<Id,Set<Id>> mapCaseIdToFileIds = new Map<Id, Set<Id>>();
            Map<Id,ContentDocumentLink> mapDocIdToContDocLink = new Map<Id,ContentDocumentLink>();
            Set<Id> linkedEntityIds = new Set<Id>();
 
            for(ContentDocumentLink objCDL: lstContentDocLink)
            {
                if(String.valueOf(objCDL.LinkedEntityId).startsWith('500'))
                {
                    if(mapCaseIdToFileIds.containsKey(objCDL.LinkedEntityId))
                    {
                        mapCaseIdToFileIds.get(objCDL.LinkedEntityId).add(objCDL.ContentDocumentId);
                    }
                    else
                    {
                        mapCaseIdToFileIds.put(objCDL.LinkedEntityId, new Set<Id>{objCDL.ContentDocumentId});
                    }
                    linkedEntityIds.add(objCDL.LinkedEntityId); 
                    mapDocIdToContDocLink.put(objCDL.ContentDocumentId,objCDL);
                }
            }
            
            Map<Id, Case> mapIdToTSCases = new Map<Id, Case>();
            Set<Id> setContentDocIds = new Set<Id>();
            
            if(linkedEntityIds.size() > 0)
            {                                                                                                             
                mapIdToTSCases = CasePortalUtil.getTSCommunityCases(linkedEntityIds);
                Datetime referencedClosedDate = System.Datetime.Now().addDays(- CasePortalUtil.FILE_UPLOAD_ALLOWED_DAYS);
                
                for(Case objCase : mapIdToTSCases.values())
                {       
                        //check if closed date is >= 30 days then dont allow to upload file
                        if(((String.valueOf(ObjCase.Status).equalsIgnoreCase(CasePortalUtil.CASE_STATUS_CLOSE) && objCase.ClosedDate != null && objCase.ClosedDate < referencedClosedDate) ||
                           String.valueOf(objCase.Status).equalsIgnoreCase(CasePortalUtil.CASE_STATUS_CANCEL)) && currentUserProfileId != internalAgentProfileId)
                        {
                            for(Id fileId : mapCaseIdToFileIds.get(objCase.Id))
                            {
                                mapDocIdToContDocLink.get(fileId).addError('Cannot upload a file.The case is closed for more than 30 days');
                            }
                        }
                        else{
                            //get Content Doc Id for TS Community Cases
                            setContentDocIds.addAll(mapCaseIdToFileIds.get(objCase.Id));    
                        }
                }
                
                List<FeedItem> lstFeedItem = new List<FeedItem>();
                Map<Id,ContentVersion> mapContentDocIdToConVersion = new Map<Id,ContentVersion>();
                
                if(setContentDocIds.size() > 0 ){
                    
                    for(Contentversion objCV : [SELECT id,ContentDocumentId,FileType,Owner.name,Title FROM ContentVersion Where ContentDocumentId In:setContentDocIds AND IsLatest = TRUE]){
                        mapContentDocIdToConVersion.put(objCV.ContentDocumentId, objCV);
                    }
                    
                    for(ContentDocumentLink objCDL: [SELECT LinkedEntityId,ContentDocument.title,ContentDocument.Owner.name,
                                                        ContentDocumentId FROM ContentDocumentLink 
                                                        WHERE ContentDocumentId IN: setContentDocIds AND LinkedEntityId In:mapIdToTSCases.KeySet() AND LinkedEntity.Type = 'Case']){
                        FeedItem objFeedItem = new FeedItem();
                        objFeedItem.ParentId = objCDL.LinkedEntityId;
                        objFeedItem.Body = objCDL.ContentDocument.title +' is uploaded by '+objCDL.ContentDocument.owner.name;
                        objFeedItem.Visibility='AllUsers';
                        objFeedItem.Type = 'ContentPost';
                        objFeedItem.Title = objCDL.ContentDocument.title;
                        if(mapContentDocIdToConVersion.containsKey(objCDL.ContentDocumentId))
                        {
                            objFeedItem.RelatedRecordId = mapContentDocIdToConVersion.get(objCDL.ContentDocumentId).Id;
                        }
                        lstFeedItem.add(objFeedItem);
                    }
                }
                if(lstFeedItem.size()>0){
                    insert lstFeedItem;
                }                          
            }
        }
    } 
    
    // Method to post information on TS Community Case Feed on Deletion of File 
    public static void postDeletionOfFileOnFeed(List<ContentDocumentLink> lstContDocLink) {
    
        Set<Id> setCaseIds = new Set<Id>();
        Set<Id> setContDocIds = new Set<Id>();
               
        if(UserInfo.getProfileId() == CasePortalUtil.INTERNAL_AGENT_PROFILE_ID){ //checking if current user is tech support agent
            for(ContentDocumentLink objCDL : lstContDocLink) {
                if(String.valueOf(objCDL.LinkedEntityId).startsWith('500')){
                    setCaseIds.add(objCDL.LinkedEntityId);
                    setContDocIds.add(objCDL.ContentDocumentId);
                }
            }
            if(setCaseIds.size() > 0){
                Map<Id,Case> mapCaseIdToCaseObj = CasePortalUtil.getTSCommunityCases(setCaseIds);
                if(mapCaseIdToCaseObj.keySet().size() > 0)
                {
                    List<FeedItem> lstFeeditem = new List<FeedItem>(); // to post feed on file deletion
                    String currentUserName = UserInfo.getName();
                    for(ContentDocumentLink objCDL :[SELECT LinkedEntityId,ContentDocument.title
                                                     FROM ContentDocumentLink WHERE ContentDocumentId IN: setContDocIds AND 
                                                        LinkedEntityId In:mapCaseIdToCaseObj.keyset() AND LinkedEntity.Type = 'Case']){
                        lstFeeditem.add(new FeedItem(ParentId = objCDL.LinkedEntityId, Body = objCDL.ContentDocument.title +' is deleted by ' + currentUserName));         
                    }
                    if(lstFeeditem.size() > 0){
                        insert lstFeeditem;    
                    }
                }
            }
        }
    }
}