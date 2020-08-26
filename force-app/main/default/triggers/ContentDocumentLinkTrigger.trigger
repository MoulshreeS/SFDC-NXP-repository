/************************************************************************
@Created By :    Gunjan Singh
@Created Date:   11 Nov 2019
@Description:    Created as part of SFDC-3465 File Upload as per conditions.
----------------------------------------------------------------------------------------*/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before delete, after insert) {
    if(trigger.isAfter)
    {
        if (Trigger.isInsert){
            //Restricting uploading of files on some criteria
            ContentDocLinkTriggerHelper.restrictUploadingFiles(Trigger.new);
        }
    }
    if(trigger.isBefore){   
        if (Trigger.isDelete){
            //Post File Deletion Information On Case Feed
            ContentDocLinkTriggerHelper.postDeletionOfFileOnFeed(Trigger.old); 
        }
    }
}