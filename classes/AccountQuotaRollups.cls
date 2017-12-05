/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AccountQuotaRollups 
 * Created By   : Dirk K (Appirio)
 * Purpose      : Calculate Participant Count fields on Account Hierarchy
 * Created Date : Jan 2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/

public class AccountQuotaRollups implements Queueable {
// implements Queueable

	// pass in unique list of communities that require roll up recalculation
	public Set<ID> setCommunities {get;set;}

	public AccountQuotaRollups(set<ID> setComm) {
		this.setCommunities = setComm;
	}

    public void execute(QueueableContext context) {
        if(!setCommunities.isEmpty()){
            calcCommunityRollups();
        }
    }

	public void calcCommunityRollups() {

		// create 1) Map for all communities with kids that have changed status,
		Map<id,account> mapCommunities = new Map<id,account>([select id, Parent.id, Parent.Parent.id from Account where id in :setCommunities]);

	// Calcuate PC counts at the Community level
		
		// 1) Zero out all count fields: aggregate result returns NO ROWS if count = 0
		// 2) create set of all affected: LPs and NOs
		Set<id> LPIDs = new Set<id>();
		Set<id> NOIDs = new Set<id>();
		for (ID commID : mapCommunities.keySet())
		{
			mapCommunities.get( commID ).PC_Available__c = 0;
			mapCommunities.get( commID ).PC_Unavailable__c = 0;
			mapCommunities.get( commID ).PC_Presponsored__c = 0;
			mapCommunities.get( commID ).PC_Sponsored__c = 0;
			mapCommunities.get( commID ).PC_Reinstateable__c = 0;
			mapCommunities.get( commID ).PC_Reserved__c = 0;
			mapCommunities.get( commID ).PC_On_Hold__c = 0;
			mapCommunities.get( commID ).PC_Newly_Enrolled__c = 0;

			LPIDs.add(mapCommunities.get(commID).Parent.id);
			NOIDs.add(mapCommunities.get(commID).Parent.Parent.id);
		}
		
		//system.debug('>>> Aggregating PCs for Communities:'+setCommunities);
		//system.debug('>>> Aggregating PCs for LPs:'+LPIDs);
		//system.debug('>>> Aggregating PCs for NOs:'+NOIDs);

		AggregateResult[] results1 = [select Community__c , count(id)mycount
								from Contact
								where
								RecordType.Name = 'Participant'
								AND rC_Sponsorship__Sponsorship_Status__c = 'Available'
								AND Community__c in :setCommunities
								group by Community__c];
		for (AggregateResult ar : results1)
			mapCommunities.get( (ID) ar.get('Community__c')).PC_Available__c = (Decimal) ar.get('mycount');

		AggregateResult[] results2 = [select Community__c , count(id)mycount
								from Contact
								where
								RecordType.Name = 'Participant'
								AND rC_Sponsorship__Sponsorship_Status__c = 'Unavailable'
								AND Community__c in :setCommunities
								group by Community__c];
		for (AggregateResult ar : results2)
			mapCommunities.get( (ID) ar.get('Community__c')).PC_Unavailable__c = (Decimal) ar.get('mycount');

		AggregateResult[] results3 = [select Community__c , count(id) mycount
								from Contact
								where
								RecordType.Name = 'Participant'
								AND rC_Sponsorship__Sponsorship_Status__c = 'Pre-Sponsored'
								AND Community__c in :setCommunities
								group by Community__c];
		for (AggregateResult ar : results3) {
				mapCommunities.get( (ID) ar.get('Community__c')).PC_Presponsored__c = (Decimal) ar.get('mycount');
		}

		AggregateResult[] results4 = [select Community__c , count(id) mycount
								from Contact
								where
								RecordType.Name = 'Participant'
								AND rC_Sponsorship__Sponsorship_Status__c = 'Sponsored'
								AND Community__c in :setCommunities
								group by Community__c];
		for (AggregateResult ar : results4) {
				mapCommunities.get( (ID) ar.get('Community__c')).PC_Sponsored__c = (Decimal) ar.get('mycount');
		}

		AggregateResult[] results5 = [select Community__c , count(id)mycount
								from Contact
								where
								RecordType.Name = 'Participant'
								AND rC_Sponsorship__Sponsorship_Status__c = 'Reinstateable'
								AND Community__c in :setCommunities
								group by Community__c];
		for (AggregateResult ar : results5)
			mapCommunities.get( (ID) ar.get('Community__c')).PC_Reinstateable__c = (Decimal) ar.get('mycount');

		AggregateResult[] results6 = [select Community__c , count(id)mycount
								from Contact
								where
								RecordType.Name = 'Participant'
								AND rC_Sponsorship__Sponsorship_Status__c = 'Reserved'
								AND Community__c in :setCommunities
								group by Community__c];
		for (AggregateResult ar : results6)
			mapCommunities.get( (ID) ar.get('Community__c')).PC_Reserved__c = (Decimal) ar.get('mycount');

		AggregateResult[] results7 = [select Community__c , count(id)mycount
								from Contact
								where
								RecordType.Name = 'Participant'
								AND rC_Sponsorship__Sponsorship_Status__c = 'On Hold'
								AND Community__c in :setCommunities
								group by Community__c];
		for (AggregateResult ar : results7)
			mapCommunities.get( (ID) ar.get('Community__c')).PC_On_Hold__c = (Decimal) ar.get('mycount');

		AggregateResult[] results8 = [select Community__c , count(id)mycount
								from Contact
								where
								RecordType.Name = 'Participant'
								AND rC_Sponsorship__Sponsorship_Status__c = 'Enrolled'
								AND Community__c in :setCommunities
								group by Community__c];
		for (AggregateResult ar : results8)
			mapCommunities.get( (ID) ar.get('Community__c')).PC_Newly_Enrolled__c = (Decimal) ar.get('mycount');


		Database.update(mapCommunities.values(),false);


	// LP roll up summaries

		AggregateResult[] groupedResultsLP = [select Parent.id parentid,
			sum(PC_Available__c)sumAvail,
			sum(PC_Unavailable__c)sumUnavail,
			sum(pc_presponsored__c)sumPreSpon,
			sum(pc_sponsored__c)sumSpon,
			sum(pc_reinstateable__c)sumRein,
			sum(pc_reserved__c)sumRes,
			sum(pc_on_hold__c)sumOnH,
			sum(pc_newly_enrolled__c)sumNEn
			from Account where
			RecordType.Name = 'Community'
			AND Parent.id IN :LPIDs
			Group by Parent.id ];

		List<Account> LPaccts = new List<Account>();
		for (AggregateResult ar : groupedResultsLP) {
			
			Account LPacct = new Account();

			LPacct.id = (id) ar.get('parentid');
			LPacct.PC_Available__c = (Decimal) ar.get('sumAvail');
			LPacct.PC_Unavailable__c = (Decimal) ar.get('sumUnavail');
			LPacct.pc_presponsored__c = (Decimal) ar.get('sumPreSpon');
			LPacct.pc_sponsored__c =  (Decimal) ar.get('sumSpon');
			LPacct.pc_reinstateable__c =  (Decimal) ar.get('sumRein');
			LPacct.pc_reserved__c = (Decimal) ar.get('sumRes');
			LPacct.pc_on_hold__c = (Decimal) ar.get('sumOnH');
			LPacct.pc_newly_enrolled__c = (Decimal) ar.get('sumNEn');

			LPaccts.add(LPacct);
		}
		Database.update(LPaccts, false);

	// NO roll up summaries

		AggregateResult[] groupedResultsNO = [select Parent.id parentid,
				sum(PC_Available__c)sumAvail,
				sum(PC_Unavailable__c)sumUnavail,
				sum(pc_presponsored__c)sumPreSpon,
				sum(pc_sponsored__c)sumSpon,
				sum(pc_reinstateable__c)sumRein,
				sum(pc_reserved__c)sumRes,
				sum(pc_on_hold__c)sumOnH,
				sum(pc_newly_enrolled__c)sumNEn				
				from Account where
				RecordType.Name = 'Local Partner'
				AND Parent.id IN :NOIDs
				Group by Parent.id ];

		List<Account> NOaccts = new List<Account>();
		for (AggregateResult ar : groupedResultsNO) {
			
			Account NOacct = new Account();

			NOacct.id = (id) ar.get('parentid');
			NOacct.PC_Available__c = (Decimal) ar.get('sumAvail');
			NOacct.PC_Unavailable__c = (Decimal) ar.get('sumUnavail');
			NOacct.pc_presponsored__c = (Decimal) ar.get('sumPreSpon');
			NOacct.pc_sponsored__c =  (Decimal) ar.get('sumSpon');
			NOacct.pc_reinstateable__c =  (Decimal) ar.get('sumRein');
			NOacct.pc_reserved__c = (Decimal) ar.get('sumRes');
			NOacct.pc_on_hold__c = (Decimal) ar.get('sumOnH');
			NOacct.pc_newly_enrolled__c = (Decimal) ar.get('sumNEn');

			NOaccts.add(NOacct);
		}
		Database.update(NOaccts, false);

	}

}