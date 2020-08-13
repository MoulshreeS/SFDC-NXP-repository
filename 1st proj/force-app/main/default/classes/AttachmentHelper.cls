// Class get created for migration of attachments to files for TS Support Cases

public class AttachmentHelper {

    // Method to delete files whenever attachment got deleted from TS Support Cases.
    public static void deleteFileOnDeletionOfAttachment(List<Attachment> lstOldAttachment){
       
        Set<Id> caseIds = new Set<Id>();
        List<String> lstAttachName = new List<String>();
        List<ContentDocumentLink> lstCurrentDoc = new List<ContentDocumentLink>();
	
        for(Attachment objAttachment:lstOldAttachment)
        {
            if(string.isNotBlank(objAttachment.parentId))
            {   
                String strParentId= objAttachment.parentId;
                if(strParentId.startsWith('500')){
                    caseIds.add(strParentId);
                    lstAttachName.add(objAttachment.Name);
                }  
            }  
        }
        Set<Id> caseTsComm=new Set<Id>();
        if(caseIds.size()>0)
        {
            List<Case> tsCommCases= [Select Id from Case Where Id IN:caseIds AND RecordType.Name='TS Community'];
            for(Case curCase:tsCommCases)
            {
                caseTsComm.add(curCase.Id);
            }
     	}
        if(caseTsComm.size()>0 && lstAttachName.size()>0){
            lstCurrentDoc=[Select ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN: caseTsComm AND ContentDocument.title In:lstAttachName];
        }
        if(lstCurrentDoc.size()>0)
        {
            List<Database.DeleteResult> result=Database.delete(lstCurrentDoc);
            for(Database.DeleteResult deleteRes:result){
                if(deleteRes.isSuccess()){
                    System.debug('Records deleted Successfully');
                }
                else{
                    for(Database.Error err: deleteRes.getErrors())
                    {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }
    
    //Method to Return ContentVersion 
    private static ContentVersion createContentVersion(String name, Blob body,Id parentId){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
        contentVersion.PathOnClient = name;
        contentVersion.Title = name;
        contentVersion.VersionData = body;
        contentVersion.ExternalDocumentInfo1 = parentId;
        return contentVersion;
    }
    
    ////Method to Return ContentDocumentLink 
    private static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId){
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.LinkedEntityId = parentId;
        contentDocumentLink.ShareType = 'I'; // Inferred permission
        contentDocumentLink.Visibility = 'AllUsers';
        return contentDocumentLink;
    }
    
    // Method to copy attachment to files for TS Support Cases
    public static void copyAttchmentToFileObject(List<Attachment> lstNewAttachment)
    {   
        Set<Id> caseIds = new Set<Id>();
        Set<Id> attachmentId = new Set<Id>();
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        List<Attachment> lstAttach = new List<Attachment>();
        List<ContentDocumentLink> lstContDocLinks = new List<ContentDocumentLink>();
        List<ContentVersion> lstInsertedContVersion = new List<ContentVersion>();
         
        for(Attachment objAttachment:lstNewAttachment)
        {   
            if(string.isNotBlank(objAttachment.parentId))
            {   
                String strParentId= objAttachment.parentId;
                if(strParentId.startsWith('500')){
                    caseIds.add(strParentId);
                    attachmentId.add(objAttachment.Id);
                }
            } 
         }
        if(caseIds.size()>0 && attachmentId.size()>0){
           lstAttach = [SELECT Id, Parent.RecordType.DeveloperName,Name,OwnerId,Body,ParentId FROM Attachment where ParentId IN:caseIds AND Id IN:attachmentId AND Parent.RecordType.DeveloperName =:'TS_Community'];
           // lstAttach = [SELECT Id, Parent.RecordType.DeveloperName,Name,OwnerId,Body,ParentId FROM Attachment where ParentId IN:caseIds AND Id IN:attachmentId];
        }
        //Insert ContentVersion
        for (integer i = 0; i < lstAttach.size(); i++) {
            ContentVersion contentVersion = createContentVersion(lstAttach[i].Name, lstAttach[i].Body,lstAttach[i].parentId);
            lstContentVersion.add(contentVersion);
        }
        if(lstContentVersion.size()>0)
        Insert lstContentVersion;
        //Insert ContentDocumentLink
        if(lstContentVersion.size()>0){
            lstInsertedContVersion = [SELECT Id, ContentDocumentId,ExternalDocumentInfo1 FROM ContentVersion WHERE Id IN :lstContentVersion];
        }
        for(ContentVersion contentVersion : lstInsertedContVersion){
            ContentDocumentLink contentDocumentLink = createContentDocumentLink(contentVersion.ContentDocumentId,contentVersion.ExternalDocumentInfo1);
            lstContDocLinks.add(contentDocumentLink);
        }
        if(lstContDocLinks.size()>0)
        insert lstContDocLinks;
     }   
    
}