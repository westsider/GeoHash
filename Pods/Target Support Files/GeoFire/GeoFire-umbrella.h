#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GFUtils.h"
#import "GFGeoQueryBounds.h"
#import "GFGeoHashQuery.h"
#import "GFGeoHash.h"
#import "GFBase32Utils.h"

FOUNDATION_EXPORT double GeoFireVersionNumber;
FOUNDATION_EXPORT const unsigned char GeoFireVersionString[];

