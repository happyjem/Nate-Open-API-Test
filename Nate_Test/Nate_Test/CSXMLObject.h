//
//  CSXMLObject.h
//  CairnStory
//  www.cairnstory.com
//
//  Created by saturna on 11. 4. 1..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString* const CSXMLObjectPublicIDKey;
extern NSString* const CSXMLObjectSystemIDKey;
extern NSString* const CSXMLObjectTextKey;
extern NSString* const CSXMLObjectAttributesKey;

@interface CSXMLObject : NSObject
	<NSXMLParserDelegate>
{
	BOOL m_ignoreWhitespace;
	NSXMLParser* m_xmlParser;

	NSMutableDictionary* m_xmlDictionary;
	NSString* m_rootDictionaryName;

	//NSMutableArray* m_elementNames;
	NSMutableArray* m_parentElements;
}

//@property (nonatomic,readonly) NSDictionary* xmlDocument;

- (id)initWithXMLData:(NSData*)xmlData andError:(NSError**)error andIgnoreWhitespace:(BOOL)ignoreWhitespace;
- (id)initWithXMLData:(NSData*)xmlData andError:(NSError**)error;

- (NSDictionary*)xmlDictionary;
- (NSDictionary*)rootDictionary;
- (NSString*)rootDictionaryName;

- (NSDictionary*)subDictionaryWithElementPath:(NSString*)path;
- (NSArray*)subArrayWithElementPath:(NSString*)path;

- (NSString*)subTextWithElementPath:(NSString*)path;
- (NSDictionary*)subAttributesWithElementPath:(NSString*)path;

@end


/*
<?xml version="1.0"?>
<PEOPLE xmlns="http://www.w3.org/2001/XMLSchema-instance">
	<PERSON ATTENDENCE="present">
		<FIRST_NAME>Sam</FIRST_NAME>
		<LAST_NAME>Edwards</LAST_NAME>
	</PERSON>
	<PERSON ATTENDENCE="absent">
		<FIRST_NAME>Sally</FIRST_NAME>
		<LAST_NAME>Jackson</LAST_NAME>
	</PERSON>
</PEOPLE>

{
    PEOPLE :
    {
        #attributes: { xmlns : "http://www.w3.org/2001/XMLSchema-instance" },
        #text      : null,
        PERSON     :
        [
		 {
			 #attributes: { ATTENDENCE : "present" },
			 #text     : null,
			 FIRST_NAME :
			 {
				 $attribute : null,
				 #text      : "Sam",
			 },
			 LAST_NAME  :
			 {
				 #attributes: null,
				 #text      : "Edwards",
			 }
		 },
		 {
			 #attributes: { ATTENDENCE : "absent" },
			 #text      : "",
			 FIRST_NAME :
			 {
				 #attributes: null,
				 #text      : "Sally",
			 },
			 LAST_NAME  :
			 {
				 #attributes: null,
				 #text      : "Jackson",
			 }
		 }
		 ]
    }
}
*/
