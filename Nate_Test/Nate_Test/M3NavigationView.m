/*****************************************************************
 M3NavigationView.m
 
 Created by Martin Pilkington on 18/11/2008.
 
 Copyright (c) 2006-2009 M Cubed Software
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 *****************************************************************/

#import "M3NavigationView.h"

@interface M3NavigationView ()
- (void)addAnimationToView:(NSView *)view;
@end


@implementation M3NavigationView

@synthesize currentViewController;


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        viewStack = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)popViewController {
	if ([viewStack count] > 1) {
		NSPoint viewOrigin = [self bounds].origin;
		NSPoint leftOrigin = NSMakePoint(viewOrigin.x - [self bounds].size.width, viewOrigin.y);
		NSPoint rightOrigin = NSMakePoint(viewOrigin.x + [self bounds].size.width, viewOrigin.y);
		
		prevViewController = [viewStack lastObject];
		[viewStack removeLastObject];
		currentViewController = [viewStack lastObject];
		[[currentViewController view] setFrameSize:[self bounds].size];
		
		if ([currentViewController respondsToSelector:@selector(willStartAnimating)]) {
			[currentViewController willStartAnimating];
		}
		if ([prevViewController respondsToSelector:@selector(willStartAnimating)]) {
			[prevViewController willStartAnimating];
		}
		
		[[prevViewController view] setFrameOrigin:viewOrigin];
		[[currentViewController view] setFrameOrigin:leftOrigin];
		
		[self addSubview:[currentViewController view]];
		
		[[[prevViewController view] animator] setFrameOrigin:rightOrigin];
		[[[currentViewController view] animator] setFrameOrigin:viewOrigin];
		
		if ([currentViewController respondsToSelector:@selector(activateView)]) {
			[currentViewController activateView];
		}
		[self setNeedsDisplay:YES];
	}
}

- (void)pushViewController:(NSViewController<M3NavigationViewControllerProtocol> *)controller {
	NSPoint viewOrigin = [self bounds].origin;
	NSPoint leftOrigin = NSMakePoint(viewOrigin.x - [self bounds].size.width, viewOrigin.y);
	NSPoint rightOrigin = NSMakePoint(viewOrigin.x + [self bounds].size.width, viewOrigin.y);
	
	NSView *newView = [controller view];
	[newView setFrameSize:[self bounds].size];
	
	[self addAnimationToView:newView];
	
	if ([currentViewController respondsToSelector:@selector(willStartAnimating)]) {
		[currentViewController willStartAnimating];
	}
	if ([controller respondsToSelector:@selector(willStartAnimating)]) {
		[controller willStartAnimating];
	}
	
	[newView setFrameOrigin:rightOrigin];
	[self addSubview:[controller view]];
	[[newView animator] setFrameOrigin:viewOrigin];
	[[[currentViewController view] animator] setFrameOrigin:leftOrigin];
	
	[viewStack addObject:controller];
	prevViewController = currentViewController;
	currentViewController = controller;
	if ([currentViewController respondsToSelector:@selector(activateView)]) {
		[currentViewController activateView];
	}
	[self setNeedsDisplay:YES];
}

- (void)setViewController:(NSViewController<M3NavigationViewControllerProtocol> *)controller {
	NSView *newView = [controller view];
	[newView setFrameSize:[self bounds].size];
	[self addAnimationToView:newView];
	
	
	[viewStack addObject:controller];
	currentViewController = controller;
	[self addSubview:newView];
	[self setNeedsDisplay:YES];
}

- (void)addAnimationToView:(NSView *)view {
	CABasicAnimation *anim = [CABasicAnimation animation];
	[anim setDelegate:self];
	[anim setDuration:0.35];
	[anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[view setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"frameOrigin"]];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	NSMutableArray *array = [[self subviews] mutableCopy];
	[array removeObject:[currentViewController view]];
	for (NSView *view in array) {
		[view removeFromSuperview];
	}
	
	if ([currentViewController respondsToSelector:@selector(didFinishAnimating)] && flag) {
		[currentViewController didFinishAnimating];
	}
	if ([prevViewController respondsToSelector:@selector(didFinishAnimating)] && flag) {
		[prevViewController didFinishAnimating];
	}
	
	prevViewController = nil;
}

@end
