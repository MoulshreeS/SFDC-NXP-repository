public class MarketSegmentationsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return MarketSegmentation__c.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			MarketSegmentation__c.Id,
			MarketSegmentation__c.Application_Label__c,
			MarketSegmentation__c.Application_Value__c,
			MarketSegmentation__c.Segment_Label__c,
			MarketSegmentation__c.Segment_Value__c,
			MarketSegmentation__c.Subsegment_Label__c,
			MarketSegmentation__c.Subsegment_Value__c
		};
	}

}