//
//  CSXMLObject.m
//  CairnStory
//  www.cairnstory.com
//
//  Created by saturna on 11. 4. 1..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CSXMLObject.h"
#import "CSCommon.h"

#pragma mark -
#pragma mark CSXMLObject (PrivateMethods)

@interface CSXMLObject (PrivateMethods)

- (NSMutableDictionary*)currentElement;

@end


NSString* const CSXMLObjectPublicIDKey = @"#PublicID";
NSString* const CSXMLObjectSystemIDKey = @"#SystemID";
NSString* const CSXMLObjectTextKey = @"#text";
NSString* const CSXMLObjectAttributesKey = @"#attributes";


#pragma mark -
#pragma mark CSXMLObject

@implementation CSXMLObject


- (id)initWithXMLData:(NSData*)xmlData andError:(NSError **)error andIgnoreWhitespace:(BOOL)ignoreWhitespace
{
	self = [super init];
	if (self == nil)
	{
		return self;
	}

	m_ignoreWhitespace = ignoreWhitespace;
	m_xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
	if (m_xmlParser == nil)
	{
		NSError *__autoreleasing aError = [[NSError alloc] initWithDomain:@"etcErrDomain"
													  code:101
												  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
															@"xml parser initializing failed", NSLocalizedDescriptionKey,
															nil]];

		error = &aError;
		return self;
	}

	[m_xmlParser setDelegate:self];
	if ([m_xmlParser parse] == NO)
	{
		NSError *__autoreleasing aError = [[NSError alloc] initWithDomain:@"etcErrDomain"
													  code:101
												  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
															@"xml parser parsing failed", NSLocalizedDescriptionKey,
															nil]];

		error = &aError;
		return self;
	}

	return self;
}


- (id)initWithXMLData:(NSData*)xmlData andError:(NSError**)error
{
	return [self initWithXMLData:xmlData andError:error andIgnoreWhitespace:YES];
}


- (NSString*)description
{
	return [NSString stringWithFormat:@"%@ - {\n"
			"	root : %@\n"
			"	xml dictionary : %@\n"
			"}",
			[self class], m_rootDictionaryName, m_xmlDictionary];
}


- (NSDictionary*)xmlDictionary
{
	return m_xmlDictionary;
}

- (NSString*)rootDictionaryName
{
	return m_rootDictionaryName;
}

- (NSDictionary*)rootDictionary
{
	return [m_xmlDictionary objectForKey:[self rootDictionaryName]];
}

- (NSDictionary*)subDictionaryWithElementPath:(NSString*)path
{
	NSArray* arrKeys = [[path substringFromIndex:1] componentsSeparatedByString:@"/"];
	//if (DEBUG) CSLog(@"====> path array : [%@]", arrKeys);

	id obj = m_xmlDictionary;
	for (NSString* key in arrKeys)
	{
		if (obj == nil)
		{
			return nil;
		}
		if ([obj isKindOfClass:[NSArray class]])
		{
			obj = [((NSArray*)obj) lastObject];
			if (obj == nil)
			{
				return nil;
			}
		}

		obj = [((NSDictionary*)obj) objectForKey:key];
	}

	return [obj isKindOfClass:[NSArray class]] ? [((NSArray*)obj) lastObject] : obj;
}


- (NSArray*)subArrayWithElementPath:(NSString*)path
{
	NSArray* arrKeys = [[path substringFromIndex:1] componentsSeparatedByString:@"/"];
	//if (DEBUG) CSLog(@"====> path array : [%@]", arrKeys);

	id obj = m_xmlDictionary;
	for (NSString* key in arrKeys)
	{
		if (obj == nil)
		{
			return nil;
		}
		if ([obj isKindOfClass:[NSArray class]])
		{
			obj = [((NSArray*)obj) lastObject];
			if (obj == nil)
			{
				return nil;
			}
		}

		obj = [((NSDictionary*)obj) objectForKey:key];
	}

	if ([obj isKindOfClass:[NSArray class]])
	{
		return obj;
	}

	NSArray* arr = [[NSArray alloc] initWithObjects:obj, nil];
	return arr;
}

- (NSString*)subTextWithElementPath:(NSString*)path
{
	NSDictionary* dic = [self subDictionaryWithElementPath:path];
	return dic == nil ? nil : [dic objectForKey:CSXMLObjectTextKey];
}


- (NSDictionary*)subAttributesWithElementPath:(NSString*)path
{
	NSDictionary* dic = [self subDictionaryWithElementPath:path];
	return dic == nil ? nil : [dic objectForKey:CSXMLObjectAttributesKey];
}


#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser*)parser
{
	//m_elementNames = [[NSMutableArray alloc] init];
	m_xmlDictionary = [[NSMutableDictionary alloc] init];
	if (EmptyString([parser publicID]) == NO)
	{
		[m_xmlDictionary setObject:[parser publicID] forKey:CSXMLObjectPublicIDKey];
	}
	if (EmptyString([parser systemID]) == NO)
	{
		[m_xmlDictionary setObject:[parser systemID] forKey:CSXMLObjectSystemIDKey];
	}

	m_parentElements = [[NSMutableArray alloc] init];
	[m_parentElements addObject:m_xmlDictionary];
}

- (void)parserDidEndDocument:(NSXMLParser*)parser
{
	m_parentElements = nil;
}





- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qName
	attributes:(NSDictionary*)attributeDict
{
//	if (DEBUG) CSLog(@"================================================>");
//	if (DEBUG) CSLog(@"elementName : %@\n"
//					 "qualifiedName : %@\n"
//					 "qName : %@\n"
//					 "attributes : %@", elementName, namespaceURI, qName, attributeDict);

	if (m_rootDictionaryName == nil)
	{
		m_rootDictionaryName = elementName;
	}

	NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
	NSMutableDictionary* parent = [m_parentElements lastObject];
	if ([parent objectForKey:elementName] == nil)
	{
		[parent setObject:dic forKey:elementName];
	}
	else
	{
		NSObject* obj = [parent objectForKey:elementName];
		if ([obj isKindOfClass:[NSMutableDictionary class]])
		{
			NSMutableArray* arr = [[NSMutableArray alloc] init];
			[arr addObject:obj];
			[arr addObject:dic];
			[parent setObject:arr forKey:elementName];
		}
		else
		{
			NSMutableArray* arr = (NSMutableArray*)obj;
			[arr addObject:dic];
		}
	}

	if (attributeDict != nil && [attributeDict count] > 0)
	{
		[dic setObject:attributeDict forKey:CSXMLObjectAttributesKey];
	}

	[m_parentElements addObject:dic];
}

- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName;
{
	NSMutableDictionary* currentElement;
	if (m_ignoreWhitespace)
	{
		currentElement = [self currentElement];
		NSString* text = [currentElement objectForKey:CSXMLObjectTextKey];
		if (text != nil)
		{
			text = Trim(text);
			if ([text length] == 0)
			{
				[currentElement removeObjectForKey:CSXMLObjectTextKey];
			}
		}
	}

	[m_parentElements removeLastObject];

	if (m_ignoreWhitespace && [currentElement count] == 0)
	{
		NSMutableDictionary* parent = [m_parentElements lastObject];
		[parent removeObjectForKey:elementName];
	}
}


- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
	NSMutableDictionary* currentElement = [self currentElement];
	NSString* text = [currentElement objectForKey:CSXMLObjectTextKey];
	if (text == nil)
	{
		text = string;
	}
	else
	{
		text = [text stringByAppendingFormat:@" %@", string];
	}
	[currentElement setObject:text forKey:CSXMLObjectTextKey];
}





#pragma mark -
#pragma mark CSXMLObject (PrivateMethods)

- (NSMutableDictionary*)currentElement
{
	NSObject* obj = [m_parentElements lastObject];
	if ([obj isKindOfClass:[NSMutableDictionary class]])
	{
		return (NSMutableDictionary*)obj;
	}

	return [((NSMutableArray*)obj) lastObject];
}



@end
