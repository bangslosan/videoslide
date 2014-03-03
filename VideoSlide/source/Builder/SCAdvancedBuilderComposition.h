//
//  SCAdvancedBuilderComposition.h
//  SlideshowCreator
//
//  Created 9/26/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBasicBuilderComposition.h"

@interface SCAdvancedBuilderComposition : SCBasicBuilderComposition

- (id)initWithComposition:(AVComposition *)composition
		 videoComposition:(AVVideoComposition *)videoComposition
				 audioMix:(AVAudioMix *)audioMix
			   titleLayer:(CALayer *)layer;


@end
