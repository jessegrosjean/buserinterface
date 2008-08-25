//
//  BUserInterface.m
//  BUserInterface
//
//  Created by Jesse Grosjean on 7/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BUserInterface.h"


@implementation NSImage (BUserInterfaceAdditions)

- (CIImage *)toCIImage {
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithData:[self TIFFRepresentation]];
    return [[CIImage alloc] initWithBitmapImageRep:bitmap];
}

- (NSImage *)toNSImage:(CIImage *)ciImage {
	CGRect extent = [ciImage extent];
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(extent.size.width, extent.size.height)];
    [image addRepresentation:[NSCIImageRep imageRepWithCIImage:ciImage]];
    return image;
}

- (NSImage *)coreImageTintedImageWithColor:(NSColor *)inTint {
	NSSize theSize = [self size];
	NSImage *theNewImage = [[NSImage alloc] initWithSize:theSize];  
	
	[theNewImage lockFocus];
	
	CGRect cg = CGRectMake(0, 0, theSize.width, theSize.height);
	CIContext* context = [[NSGraphicsContext currentContext] CIContext];
	
	if (context != nil) {
        CIImage *image = [self toCIImage];
		CIColor *color = [[CIColor alloc] initWithColor:inTint];
		CIFilter *filter = [CIFilter filterWithName:@"CIWhitePointAdjust" keysAndValues:@"inputImage", image, @"inputColor", color, nil];
		[context drawImage:[filter valueForKey: @"outputImage"] atPoint:cg.origin fromRect:cg];
	}
	
	[theNewImage unlockFocus];
	
	return theNewImage;
}

- (NSImage *)tintedImageWithColor:(NSColor *)inTint {
	return [self tintedImageWithColor:inTint operation:NSCompositeSourceAtop];
}

- (NSImage *)tintedImageWithColor:(NSColor *)inTint operation:(NSCompositingOperation)inOperation {
	NSSize theSize = [self size];
	NSImage *theNewImage = [[NSImage alloc] initWithSize:theSize];  
	
	[theNewImage lockFocus];
	
	[self compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];  
	[inTint set]; 
	NSRectFillUsingOperation(NSMakeRect(0, 0, theSize.width, theSize.height), inOperation); 
	
	[theNewImage unlockFocus];
	
	return theNewImage;
}

@end

@implementation NSMenu (BUserInterfaceAdditions)

- (NSMenuItem *)itemWithRepresentedObject:(id)representedObject {
	for (NSMenuItem *each in [self itemArray]) {
		if ([[each representedObject] isEqual:representedObject]) {
			return each;
		}
	}
	return nil;
}

@end