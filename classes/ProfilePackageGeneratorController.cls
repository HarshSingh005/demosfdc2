public class ProfilePackageGeneratorController
{
	public string packageXML{get;set;}
	
	public ProfilePackageGeneratorController() 
	{
		this.GeneratePackage();
	}

	public void GeneratePackage()
	{
		MetadataService.MetadataPort service = createService();     
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
        
        this.CreateQuery(queries, 'CustomApplication');
        this.CreateQuery(queries, 'ApexClass');
        this.CreateQuery(queries, 'ExternalDataSource');
        this.CreateQuery(queries, 'Layout');
        this.CreateQuery(queries, 'ApexPage');
        this.CreateQuery(queries, 'RecordType');
        this.CreateQuery(queries, 'CustomTab');
        this.CreateQuery(queries, 'CustomObject');
        this.CreateQuery(queries, 'CustomField');
        this.CreateQuery(queries, 'Profile');  

        Map<string, List<string>> metadataMap = new Map<string, List<string>>();

        //can only query 3 types at a time, so loop through and add to query list until it contains
        //a max of 3 type queries, then call query function
        

        List<MetadataService.ListMetadataQuery> queryTemp = new List<MetadataService.ListMetadataQuery>();
        for(integer index = 0; index < queries.size(); index++)
        {
        	MetadataService.ListMetadataQuery query = queries.get(index);
        	queryTemp.add(query);
        	
        	if(queryTemp.size() == 3 || index == queries.size() - 1)
        	{
        		this.RunMetadataQuery(service, queryTemp, metadataMap);
        		queryTemp.clear();
        	}
        }

        //sort metadata lists
        for(List<string> typeList : metadataMap.values())
        	typeList.sort();

    	this.CreateXML(metadataMap);
            	
	}


	private void RunMetadataQuery(MetadataService.MetadataPort service, List<MetadataService.ListMetadataQuery> queries, Map<string, List<string>> metadataMap)
	{
		MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 38);

        //create metadata lists
        for(MetadataService.FileProperties fileProperty : fileProperties)
        {
        	List<string> typeList;

        	if(metadataMap.containsKey(fileProperty.type_x))
        	{
        		typeList = metadataMap.get(fileProperty.type_x);
        	}
        	else
        	{
        		typeList = new List<string>();
        		metadataMap.put(fileProperty.type_x, typeList);
        	}

        	if(!fileProperty.fullName.startsWith('ProfilePackageGenerator'))
        		typeList.add(fileProperty.fullName.trim());
        }
	}

	private void CreateQuery(List<MetadataService.ListMetadataQuery> queries, string metatype)
	{
		MetadataService.ListMetadataQuery query = new MetadataService.ListMetadataQuery();
        query.type_x = metatype;
        queries.add(query);
	}

	private void CreateXML(Map<string, List<string>> metadataMap)
	{
		XmlStreamWriter w = new XmlStreamWriter();
		w.writeStartDocument('UTF-8', '1.0');
		
		w.writeStartElement(null, 'Package', null);
		w.writeAttribute(null, null, 'xmlns', 'http://soap.sforce.com/2006/04/metadata');
		
		w.writeStartElement(null, 'fullName', null);
		w.writeCharacters('ProfilePackageGenerator');
		w.writeEndElement(); 

		w.writeStartElement(null, 'description', null);
		w.writeCharacters('Package.xml to retrieve alll Profile related metadata elements');
		w.writeEndElement(); 

		//iterate through keys in metadataMap and create types with members in xml
		for(string metatype : metadataMap.keySet())
			this.WriteType(w, metatype, metadataMap.get(metatype));
		
		w.writeStartElement(null, 'version', null);
		w.writeCharacters('38.0');
		w.writeEndElement(); 
		
		w.writeEndElement(); //end Package

		w.writeEndDocument();
		
		this.packageXML = w.getXmlString();

		w.close();
	}

	private void WriteType(XmlStreamWriter w, string metatype, List<string> members)
	{
		w.writeStartElement(null, 'types', null);

		for(string member : members)
		{
			w.writeStartElement(null, 'members', null);
			w.writeCharacters(member);
			w.writeEndElement(); // end members
		}

		w.writeStartElement(null, 'name', null);
		w.writeCharacters(metatype);
		w.writeEndElement(); // end name

		w.writeEndElement(); //end types
	}

	private MetadataService.MetadataPort createService()
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
}