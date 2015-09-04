//
//  AudioHelper.h
//  transients
//
//  Created by Johann Diedrick on 9/2/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

#ifndef transients_AudioHelper_h
#define transients_AudioHelper_h

#import <Foundation/Foundation.h>

typedef void(^myCompletion)(BOOL);

@interface AudioHelper : NSObject

@property (strong, nonatomic) id someProperty;

+ (void)convertFromWavToMp3:(NSString*)fileName block:(myCompletion) compblock;

@end

#endif
