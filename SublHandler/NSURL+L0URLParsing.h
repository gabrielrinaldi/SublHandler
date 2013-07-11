//
//  NSURL+L0URLParsing.h
//
//  Created by Diceshaker on 11/02/09.
//

#import <Foundation/Foundation.h>


@interface NSURL (L0URLParsing)

- (NSDictionary *)dictionaryByDecodingQueryString;

@end

@interface NSDictionary (L0URLParsing)

- (NSString *)queryString;

@end
