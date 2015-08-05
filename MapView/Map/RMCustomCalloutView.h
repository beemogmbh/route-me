//
//  RMCustomCalloutView.h
//  MapView
//
//  Created by Daniel Christoph on 05.08.15.
//
//

#ifndef MapView_RMCustomCalloutView_h
#define MapView_RMCustomCalloutView_h

#import "SMCalloutView.h"


@interface RMCustomCalloutView : SMCalloutBackgroundView

- (id)initWithFrame:(CGRect)frame andBackgroundColor:(UIColor*)backgroundColor withHighlightedBackgroundColor:(UIColor*)highlightedBackgroundColor;

@end

#endif
