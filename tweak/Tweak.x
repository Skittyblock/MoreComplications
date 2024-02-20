#import <Foundation/Foundation.h>
#import <rootless.h>
#import "Tweak.h"

#define BUNDLE_ID @"xyz.skitty.morecomplications"
#define ELEMENTS_PER_ROW 4

static NSMutableDictionary *settings;
static BOOL enabled = YES;
static int rows = 2;

%hook CSGraphicComplicationLayoutProvider

// allow adding more elements to the complication
+ (bool)canAddElement:(CSComplicationLayoutElement *)element toElements:(NSArray<CSComplicationLayoutElement *> *)elements {
	if (!enabled) return %orig;
	long long totalWidth = 0;
	for (CSComplicationLayoutElement *element in elements) {
		totalWidth += element.gridWidth;
	}
	return totalWidth + element.gridWidth <= rows * ELEMENTS_PER_ROW;
}

// change the height of the complication container to fit more rows
+ (double)complicationContainerHeight {
	double complicationContainerHeight = %orig;
	if (!enabled) return complicationContainerHeight;
	double spacing = [%c(CSGraphicComplicationLayoutProvider) complicationEdgeInset];
	return complicationContainerHeight * rows + spacing * (rows - 1);
}

// handle the positions of the complications
+ (NSDictionary<CSComplicationLayoutElement *, NSValue *> *)_framesForLayoutElements:(NSArray<CSComplicationLayoutElement *> *)elements containerSize:(CGSize)containerSize {
	if (!enabled) return %orig;

	NSMutableArray *groups = [NSMutableArray new];
	NSMutableArray *groupWidths = [NSMutableArray new];
	for (int i = 0; i < rows; ++i) {
		[groups addObject:[NSMutableArray new]];
		[groupWidths addObject:@0];
	}

	// put each element in the first group that can fit it
	for (CSComplicationLayoutElement *element in elements) {
		for (int i = 0; i < [groupWidths count]; i++) {
			if ([groupWidths[i] intValue] + element.gridWidth <= ELEMENTS_PER_ROW) {
				groupWidths[i] = @([groupWidths[i] intValue] + element.gridWidth);
				[groups[i] addObject:element];
				break;
			}
		}
	}

	// get the original container size so we can reuse the original function
	double spacing = [%c(CSGraphicComplicationLayoutProvider) complicationEdgeInset];
	CGSize smallContainerSize = containerSize;
	smallContainerSize.height -= spacing * (rows - 1);
	smallContainerSize.height /= rows;

	NSMutableDictionary<CSComplicationLayoutElement *, NSValue *> *newFrames = [NSMutableDictionary dictionary];

	for (int i = 0; i < [groups count]; i++) {
		NSArray<CSComplicationLayoutElement *> *group = groups[i];
		if ([group count] == 0) {
			break;
		}
		NSDictionary<CSComplicationLayoutElement *, NSValue *> *frames = %orig(group, smallContainerSize);
		for (CSComplicationLayoutElement *element in frames) {
			NSRect frame = [frames[element] CGRectValue];
			frame.origin.y += i * (smallContainerSize.height + spacing);
			newFrames[element] = [NSValue valueWithCGRect:frame];
		}
	}

	return newFrames;
}

%end

// Preference updates
void refreshPrefs() {
	CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)BUNDLE_ID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)BUNDLE_ID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		settings = nil;
	}
	if (!settings) {
		NSString *settingsPath = ROOT_PATH_NS(@"/var/mobile/Library/Preferences/");
		settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@%@.plist", settingsPath, BUNDLE_ID]];
	}

	enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
	rows = [([settings objectForKey:@"rows"] ?: @(2)) intValue];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  refreshPrefs();
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, (CFStringRef)[NSString stringWithFormat:@"%@.prefschanged", BUNDLE_ID], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	refreshPrefs();
}
