public class ContentDocumentLinksSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return ContentDocumentLink.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			ContentDocumentLink.Id,
			ContentDocumentLink.ContentDocumentId,
			ContentDocumentLink.LinkedEntityId,
			ContentDocumentLink.ShareType
		};
	}
	
	public override String getOrderBy() {
		return 'Id'; // By default, the result is ordered by 'CreatedDate', which does not exist in ContentDocumentLink. 
	}
	
	public List<ContentDocumentLink> selectByContentDocumentId(Set<Id> docIds) {
		p('selectByContentDocumentId');
		// ContentDocumentLink does not allow predicate to be empty.
		return docIds.isEmpty() ? new List<ContentDocumentLink>() : (List<ContentDocumentLink>)Database.query(newQueryFactory().setCondition('ContentDocumentId in :docIds').toSOQL());
	}
	
	public List<ContentDocumentLink> selectByOpptyIdWithContentDocument(Set<Id> opptyIds) {
		p('selectByOpptyIdWithContentDocument');
		fflib_QueryFactory contentDocLinksQueryFactory = newQueryFactory();
		
		new ContentDocumentsSelector().configureQueryFactoryFields(contentDocLinksQueryFactory, ContentDocumentLink.ContentDocumentId.getDescribe().getRelationshipName());
		
		contentDocLinksQueryFactory.selectField(ContentDocumentLink.ContentDocumentId.getDescribe().getRelationshipName() + '.' + ContentDocument.LatestPublishedVersionId.getDescribe().getRelationshipName() + '.' + ContentVersion.Category__c);	
		
		// ContentDocumentLink does not allow predicate to be empty.
		return opptyIds.isEmpty() ? new List<ContentDocumentLink>() : (List<ContentDocumentLink>)Database.query(contentDocLinksQueryFactory.setCondition('LinkedEntityId in :opptyIds').toSOQL());
	}

}